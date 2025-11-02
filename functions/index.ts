// functions/index.ts
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import axios from "axios";

admin.initializeApp();

// --- Environment Configuration ---
const WEATHER_API_KEY = functions.config().weather?.key;
const AI_API_KEY = functions.config().ai?.key;

// --- FUNCTION 1: Daily Weather Alerts ---
export const sendDailyWeatherAlerts = functions.pubsub
  .schedule("0 8 * * *")
  .timeZone("Asia/Karachi")
  .onRun(async (context) => {
    console.log("Running daily weather alerts...");
    
    try {
      // Get all users who want weather alerts
      const usersSnapshot = await admin.firestore()
        .collection("users")
        .where("weatherAlertsEnabled", "==", true)
        .get();

      if (usersSnapshot.empty) {
        console.log("No users with weather alerts enabled");
        return null;
      }

      // Process each user
      for (const userDoc of usersSnapshot.docs) {
        const userData = userDoc.data();
        const location = userData.location || "Lahore";
        
        try {
          // Fetch weather (you'll need to implement this based on your weather API)
          const weatherUrl = `http://api.openweathermap.org/data/2.5/weather?q=${location}&appid=${fee1d96b1414c7187e5237cc5639e298}&units=metric`;
          const weatherRes = await axios.get(weatherUrl);
          
          const temp = weatherRes.data.main.temp;
          const description = weatherRes.data.weather[0].description;
          
          // Create notification
          await admin.firestore().collection("notifications").add({
            userId: userDoc.id,
            title: "Daily Weather Update",
            message: `${location}: ${temp}°C, ${description}`,
            type: "weather",
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          
        } catch (err) {
          console.error(`Error fetching weather for user ${userDoc.id}:`, err);
        }
      }
      
      console.log("Weather alerts sent successfully");
    } catch (error) {
      console.error("Error in weather alerts function:", error);
    }
    
    return null;
  });

// --- FUNCTION 2: AI Query Response ---
export const getAIResponseForQuery = functions.firestore
  .document("queries/{queryId}")
  .onCreate(async (snap, context) => {
    const queryData = snap.data();
    const question = queryData.question;
    const queryId = context.params.queryId;

    if (!question || queryData.aiResponse) {
      console.log("No question or response already exists. Exiting.");
      return null;
    }

    console.log(`New question from ${queryData.userID}: "${question}"`);

    // Prepare the AI prompt
    const prompt = {
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content:
            "You are Verda, a helpful farming assistant for farmers in Pakistan. You must answer in both simple English and Urdu (using Roman Urdu/Urdu script). Provide clear, actionable advice.",
        },
        { role: "user", content: question },
      ],
    };

    try {
      // Call the AI API (OpenRouter)
      const aiRes = await axios.post(
        "https://openrouter.ai/api/v1/chat/completions",
        prompt,
        {
          headers: {
            "Authorization": `Bearer ${AI_API_KEY}`,
            "Content-Type": "application/json",
            "HTTP-Referer": "https://farming-app.com", // Optional
            "X-Title": "Verda Farming Assistant", // Optional
          },
        }
      );

      const aiResponse = aiRes.data.choices[0].message.content;

      // Write the answer back to Firestore
      await admin.firestore().collection("queries").doc(queryId).update({
        aiResponse: aiResponse,
        status: "completed",
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("Successfully answered query.");
      return null;
      
    } catch (error: any) {
      console.error("Error getting AI response:", error.response?.data || error.message);
      
      // Write error back to Firestore
      await admin.firestore().collection("queries").doc(queryId).update({
        aiResponse: "Sorry, an error occurred. Please try again. \n\nمعذرت، ایک خرابی پیش آ گئی ہے۔ براہ مہربانی دوبارہ کوشش کریں.",
        status: "error",
        errorAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return null;
    }
  });

// --- FUNCTION 3: Post Crop for Sale ---
export const postCropForSale = functions.https.onCall(
  async (data, context) => {
    // Check authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to post."
      );
    }

    // Validate data
    const { cropName, urduName, quantity, price, unit, description, location } = data;
    
    if (!cropName || !quantity || !price || !unit) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields: cropName, quantity, price, unit"
      );
    }

    // Validate data types
    if (typeof quantity !== "number" || typeof price !== "number") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Quantity and price must be numbers"
      );
    }

    if (quantity <= 0 || price <= 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Quantity and price must be positive numbers"
      );
    }

    const uid = context.auth.uid;

    try {
      // Get user info for the listing
      const userDoc = await admin.firestore().collection("users").doc(uid).get();
      const userData = userDoc.data();

      // Add to crops_for_sale collection
      const cropRef = await admin.firestore().collection("crops_for_sale").add({
        sellerId: uid,
        sellerName: userData?.name || "Anonymous",
        sellerPhone: userData?.phone || "",
        sellerLocation: location || userData?.location || "",
        cropName: cropName,
        urduName: urduName || "",
        quantity: quantity,
        price: price,
        unit: unit,
        description: description || "",
        status: "available",
        postedAt: admin.firestore.FieldValue.serverTimestamp(),
        views: 0,
      });

      console.log(`New crop posted by ${uid}: ${quantity} ${unit} of ${cropName}`);
      
      return { 
        success: true, 
        message: "Crop posted successfully!",
        cropId: cropRef.id 
      };
      
    } catch (error: any) {
      console.error("Error posting crop:", error);
      throw new functions.https.HttpsError(
        "internal",
        `An error occurred while posting your crop: ${error.message}`
      );
    }
  }
);

// --- FUNCTION 4: Update Market Rates (Admin) ---
export const updateMarketRates = functions.https.onCall(
  async (data, context) => {
    // Check authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in."
      );
    }

    // TODO: Add admin check
    // const userDoc = await admin.firestore().collection("users").doc(context.auth.uid).get();
    // if (!userDoc.data()?.isAdmin) {
    //   throw new functions.https.HttpsError("permission-denied", "Admin access required");
    // }

    const rates = data.rates;
    
    if (!Array.isArray(rates) || rates.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Rates must be a non-empty array"
      );
    }

    const db = admin.firestore();
    const batch = db.batch();
    const collectionRef = db.collection("market_rates");

    console.log("Updating market rates...");

    rates.forEach((rate: any) => {
      // Validate each rate object
      if (!rate.name || !rate.price || !rate.unit) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "Each rate must have name, price, and unit"
        );
      }

      // Use crop name (lowercase) as document ID for easy lookup
      const docId = rate.name.toLowerCase().replace(/\s+/g, '_');
      const docRef = collectionRef.doc(docId);
      
      batch.set(docRef, {
        name: rate.name,
        urduName: rate.urduName || "",
        price: parseFloat(rate.price),
        unit: rate.unit,
        region: rate.region || "Punjab",
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    try {
      await batch.commit();
      console.log("Successfully updated market rates.");
      return { 
        success: true, 
        message: `${rates.length} market rates updated successfully` 
      };
    } catch (error: any) {
      console.error("Error updating market rates:", error);
      throw new functions.https.HttpsError(
        "internal",
        `Error updating rates: ${error.message}`
      );
    }
  }
);

// --- FUNCTION 5: Mark Crop as Sold ---
export const markCropAsSold = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in"
      );
    }

    const { cropId } = data;
    
    if (!cropId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "cropId is required"
      );
    }

    try {
      const cropRef = admin.firestore().collection("crops_for_sale").doc(cropId);
      const cropDoc = await cropRef.get();

      if (!cropDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Crop listing not found"
        );
      }

      // Verify the user owns this listing
      if (cropDoc.data()?.sellerId !== context.auth.uid) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "You can only update your own listings"
        );
      }

      await cropRef.update({
        status: "sold",
        soldAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return { success: true, message: "Crop marked as sold" };
      
    } catch (error: any) {
      console.error("Error marking crop as sold:", error);
      throw new functions.https.HttpsError(
        "internal",
        error.message || "An error occurred"
      );
    }
  }
);

// --- FUNCTION 6: Delete Crop Listing ---
export const deleteCropListing = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in"
      );
    }

    const { cropId } = data;
    
    if (!cropId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "cropId is required"
      );
    }

    try {
      const cropRef = admin.firestore().collection("crops_for_sale").doc(cropId);
      const cropDoc = await cropRef.get();

      if (!cropDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "Crop listing not found"
        );
      }

      // Verify ownership
      if (cropDoc.data()?.sellerId !== context.auth.uid) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "You can only delete your own listings"
        );
      }

      await cropRef.delete();

      return { success: true, message: "Listing deleted successfully" };
      
    } catch (error: any) {
      console.error("Error deleting crop listing:", error);
      throw new functions.https.HttpsError(
        "internal",
        error.message || "An error occurred"
      );
    }
  }
);