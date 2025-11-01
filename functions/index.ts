// Import Firebase Admin SDK
const admin = require("firebase-admin");
const functions = require("firebase-functions");
const axios = require("axios"); // To make API calls

admin.initializeApp();

// (You would need to set your API key in the function's environment)
// firebase functions:config:set weather.key="YOUR_WEATHER_API_KEY"
const WEATHER_API_KEY = functions.config().weather.key;

/**
 * Scheduled function to send daily weather alerts.
 * Runs every day at 8:00 AM (Pakistan Standard Time).
 */
exports.sendDailyWeatherAlerts = functions.pubsub
  .schedule("0 8 * * *")
  .timeZone("Asia/Karachi") // Set to Pakistan Standard Time
  .onRun(async (context) => {
    console.log("Running daily weather alert job...");

    // 1. Get all users (in a real app, you'd get their tokens and locations)
    // For this demo, we'll just fetch for a sample location.
    const location = "Lahore";
    const weatherUrl = `https://api.weatherapi.com/v1/forecast.json?key=${WEATHER_API_KEY}&q=${location}&days=1&aqi=no&alerts=yes`;

    try {
      // 2. Fetch weather data
      const weatherRes = await axios.get(weatherUrl);
      const forecast = weatherRes.data.forecast.forecastday[0].day;
      const condition = forecast.condition.text;
      const maxTemp = forecast.maxtemp_c;
      const minTemp = forecast.mintemp_c;
      const rainChance = forecast.daily_chance_of_rain;

      // 3. Create the notification message
      const title = `Weather in ${location} Today (آج کا موسم)`;
      const body = `H: ${maxTemp}°C, L: ${minTemp}°C. ${condition}. Rain: ${rainChance}%.\n\n ${location} میں موسم: زیادہ سے زیادہ ${maxTemp}°، کم سے کم ${minTemp}°۔ ${condition}۔ بارش کا امکان: ${rainChance}%۔`;

      const payload = {
        notification: {
          title: title,
          body: body,
        },
      };

      // 4. Send notification via FCM
      // This sends the message to a "weather" topic that all users would be subscribed to.
      await admin.messaging().sendToTopic("weather", payload);
      console.log("Successfully sent weather alerts.");
      
    } catch (error) {
      console.error("Error sending weather alerts:", error);
    }
  });