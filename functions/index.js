const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/*
====================================================
SMART FARMING IoT + FUZZY LOGIC
Berdasarkan PDF Indoor Plant Light & Moisture
====================================================
*/

const plants = require("./shared/plant_profiles.json");

/*
====================================================
REFERENCE RANGE DARI PDF
====================================================
*/

function getLightRange(level) {
  if (level === "low") {
    return {min: 270, max: 807};
  }

  if (level === "medium") {
    return {min: 807, max: 1614};
  }

  return {min: 1614, max: 10764}; // high
}

function getWaterRange(type) {
  if (type === "dry") {
    return {min: 20, max: 40};
  }

  if (type === "moist") {
    return {min: 40, max: 70};
  }

  return {min: 70, max: 90}; // wet
}

/*
====================================================
MAIN FUNCTION
====================================================
*/

exports.autoControl = functions
  .region("asia-southeast1")
  .database
  .ref("/iotani/sensor")
  .onWrite(async (change, context) => {
      try {
        const data = change.after.val();
        if (!data) return null;

        const kelembapan = data.kelembapan || 0; // %
        const cahaya = data.cahaya || 0; // lux
        const plantIndex = data.plantIndex || 0;

        const db = admin.database();
        const controlSnap = await db.ref("/iotani/control").once("value");
        const control = controlSnap.val() || {};
        const profile = control.plantProfile || {};

        const plant = plants[plantIndex] || plants[0];

        const fallbackSoilRange = getWaterRange(plant.water);
        const fallbackLightRange = getLightRange(plant.light);

        const soilRange = {
          min: toNumber(profile.soilMin, fallbackSoilRange.min),
          max: toNumber(profile.soilMax, fallbackSoilRange.max),
        };
        const lightRange = {
          min: toNumber(profile.lightMin, fallbackLightRange.min),
          max: toNumber(profile.lightMax, fallbackLightRange.max),
        };

        const soilFuzzyBand = toNumber(
            profile.soilFuzzyBand,
            Math.max(10, Math.round((soilRange.max - soilRange.min) / 2)),
        );
        const lightFuzzyBand = toNumber(
            profile.lightFuzzyBand,
            Math.max(50, Math.round((lightRange.max - lightRange.min) * 0.15)),
        );

        const activePlant = {
          id: profile.id || null,
          name: profile.name || (plant.plant && plant.plant.name) || "Unknown",
          category: profile.category || "Hias",
        };

        let pompa = "OFF";
        let lampu = "OFF";
        let riskStatus = "aman";

        /*
      ============================================
      FUZZY MEMBERSHIP
      ============================================
      */

        function fuzzyLow(value, minIdeal, band) {
          if (value <= minIdeal) return 1;
          if (value < minIdeal + band) {
            return (minIdeal + band - value) / band;
          }
          return 0;
        }

        function fuzzyHigh(value, maxIdeal, band) {
          if (value >= maxIdeal) return 1;
          if (value > maxIdeal - band) {
            return (value - (maxIdeal - band)) / band;
          }
          return 0;
        }

        const dry = fuzzyLow(kelembapan, soilRange.min, soilFuzzyBand);
        const wet = fuzzyHigh(kelembapan, soilRange.max, soilFuzzyBand);

        const dark = fuzzyLow(cahaya, lightRange.min, lightFuzzyBand);
        const bright = fuzzyHigh(cahaya, lightRange.max, lightFuzzyBand);

        /*
      ============================================
      RISK STATUS
      ============================================
      */

        if (
          (dry >= 0.7 && dark >= 0.7) ||
        (wet >= 0.7 && bright >= 0.7)
        ) {
          riskStatus = "risiko_tinggi";
        } else if (
          dry > 0 ||
        wet > 0 ||
        dark > 0 ||
        bright > 0
        ) {
          riskStatus = "waspada";
        }

        /*
      ============================================
      UPDATE FIREBASE
      ============================================
      */
// =======================
// CEK MODE
// =======================
const modeSnap = await db.ref("/iotani/control/mode").once("value");
const mode = modeSnap.val() || "auto";

// =======================
// INIT STATE
// =======================
let finalPompa = "OFF";
let finalLampu = "OFF";
let lastPompaUpdate = 0;
let lastLampuUpdate = 0;

// =======================
// MODE MANUAL
// =======================
if (mode === "manual") {

  const manualSnap = await db.ref("/iotani/manual").once("value");
  const manual = manualSnap.val() || {};

  finalPompa = manual.pompa || "OFF";
  finalLampu = manual.lampu || "OFF";

} else {

  // =======================
  // AUTO MODE (FUZZY + PREV)
  // =======================
  const prev = control;

  let prevPompa = prev.pompa || "OFF";
  let prevLampu = prev.lampu || "OFF";
  lastPompaUpdate = prev.pompaUpdatedAt || 0;
  lastLampuUpdate = prev.lampuUpdatedAt || 0;

  finalPompa = prevPompa;
  finalLampu = prevLampu;

  const now = Date.now();
  const MIN_DURATION = 3000;

  const pumpON = dry;
  const pumpOFF = wet;

  // ===== POMPA =====
  if (prevPompa === "OFF") {
    if (pumpON > pumpOFF && pumpON >= 0.4 && (now - lastPompaUpdate > MIN_DURATION)) {
      finalPompa = "ON";
      lastPompaUpdate = now;
    }
  } else {
    if ((pumpOFF > pumpON && pumpOFF >= 0.3 || kelembapan > 40) && (now - lastPompaUpdate > MIN_DURATION)) {
      finalPompa = "OFF";
      lastPompaUpdate = now;
    }
  }

  // ===== LAMPU =====
  const lampON = dark;
  const lampOFF = bright;

  if (prevLampu === "OFF") {
    if (lampON > lampOFF && lampON >= 0.4 && (now - lastLampuUpdate > MIN_DURATION)) {
      finalLampu = "ON";
      lastLampuUpdate = now;
    }
  } else {
    if (lampOFF > lampON && lampOFF >= 0.3 && (now - lastLampuUpdate > MIN_DURATION)) {
      finalLampu = "OFF";
      lastLampuUpdate = now;
    }
  }
}

// =======================
// UPDATE FIREBASE
// =======================
await db.ref("/iotani/control").update({
  pompa: finalPompa,
  lampu: finalLampu,
  mode,
  riskStatus,
  plant: activePlant,
  threshold: {
    soilMin: soilRange.min,
    soilMax: soilRange.max,
    lightMin: lightRange.min,
    lightMax: lightRange.max,
    soilFuzzyBand,
    lightFuzzyBand,
  },
  pompaUpdatedAt: lastPompaUpdate,
  lampuUpdatedAt: lastLampuUpdate,
  updatedAt: Date.now(),
});

await db.ref("/iotani/status").update({
  kelembapan,
  cahaya,
  pompa: finalPompa,
  lampu: finalLampu,
  riskStatus,
  plant: activePlant,
  threshold: {
    soilMin: soilRange.min,
    soilMax: soilRange.max,
    lightMin: lightRange.min,
    lightMax: lightRange.max,
    soilFuzzyBand,
    lightFuzzyBand,
  },
  lightRequirement: plant.light,
  waterRequirement: plant.water,
  lastUpdate: Date.now(),
});

       console.log("Updated:", activePlant.name);

        return null;
      } catch (error) {
        console.error(error);
        return null;
      }
    });

function toNumber(value, fallback) {
  const n = Number(value);
  if (Number.isFinite(n)) return n;
  return fallback;
}
    
