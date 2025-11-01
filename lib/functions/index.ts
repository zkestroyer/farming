// D:\Farming\farming\lib\functions\index.ts
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import axios from "axios";

admin.initializeApp();

// --- Environment Configuration ---
// Run these commands in your PowerShell:
// firebase functions:config:set weather.key="YOUR_WEATHER_API_KEY"
// firebase functions:config:set ai.key="YOUR_OPENROUTER_API_KEY"
const WEATHER_API_KEY = functions.config().weather.key;
const AI_API_KEY = functions.config().ai.key;

/**
 * Scheduled function to send daily weather alerts.
 * Runs every day at 8:00 AM (Pakistan Standard Time).
 */
export const sendDailyWeatherAlerts = functions.pubsub
  .schedule("0 8 * * *")
  .timeZone("Asia/Karachi")
  .onRun(async (context) => {
    console.log("Running daily weather alert job...");

    const location = "Lahore"; // You can customize this
    const weatherUrl = `https://api.weatherapi.com/v1/forecast.json?key=${WEATHER_API_KEY}&q=${location}&days=1&aqi=no&alerts=yes`;

    try {
      const weatherRes = await axios.get(weatherUrl);
      const forecast = weatherRes.data.forecast.forecastday[0].day;
      const condition = forecast.condition.text;
      const maxTemp = forecast.maxtemp_c;
      const minTemp = forecast.mintemp_c;
      const rainChance = forecast.daily_chance_of_rain;

      const title = `Weather in ${location} Today (آج کا موسم)`;
      const body = `H: ${maxTemp}°C, L: ${minTemp}°C. ${condition}. Rain: ${rainChance}%.\n\n ${location} میں موسم: زیادہ سے زیادہ ${maxTemp}°، کم سے کم ${minTemp}°۔ ${condition}۔ بارش کا امکان: ${rainChance}%۔`;

      const payload = {
        notification: {
          title: title,
          body: body,
        },
      };

      await admin.messaging().sendToTopic("weather", payload);
      console.log("Successfully sent weather alerts.");
    } catch (error) {
      console.error("Error sending weather alerts:", error);
    }
  });

/**
 * Triggers when a new query is created in the 'queries' collection.
 * It fetches an AI response and writes it back to the document.
 */
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

    const prompt = {
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content:
            "You are Verda, a helpful farming assistant for farmers in Pakistan. You must answer in both simple English and Urdu (using Roman Urdu/Urdu script). Provide clear, actionable advice.",
        },
        {role: "user", content: question},
      ],
    };

    try {
      const aiRes = await axios.post(
        "https://api.openrouter.ai/v1/chat/completions",
        prompt,
        {
          headers: {
            "Authorization": `Bearer ${AI_API_KEY}`,
            "Content-Type": "application/json",
          },
        }
      );

      // Extract the text response
      const aiResponse = aiRes.data.choices[0].message.content;

      // Update the document in Firestore
      await admin.firestore().collection("queries").doc(queryId).update({
        aiResponse: aiResponse,
        status: "completed",
      });

      console.log("Successfully answered query.");
      return null;
    } catch (error) {
      console.error("Error getting AI response:", error);
      await admin.firestore().collection("queries").doc(queryId).update({
        aiResponse: "Sorry, an error occurred. Please try again. \n\nمعذرت، ایک خرابی پیش آ گئی ہے۔ براہ مہربانی دوبارہ کوشش کریں.",
        status: "error",
      });
      return null;
    }
  });