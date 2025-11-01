// (Add this to your functions/index.js file)

// (Set your OpenRouter key in the environment)
// firebase functions:config:set ai.key="YOUR_OPENROUTER_API_KEY"
const AI_API_KEY = functions.config().ai.key;

/**
 * Triggers when a new query is created in the 'queries' collection.
 * It fetches an AI response and writes it back to the document.
 */
exports.getAIResponseForQuery = functions.firestore
  .document("queries/{queryId}")
  .onCreate(async (snap, context) => {
    const queryData = snap.data();
    const question = queryData.question;
    const queryId = context.params.queryId;

    if (!question || queryData.aiResponse) {
      // Do nothing if there's no question or if a response already exists
      console.log("No question or response already exists. Exiting.");
      return null;
    }

    console.log(`New question from ${queryData.userID}: "${question}"`);

    // 1. Prepare the AI prompt
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
      // 2. Call the AI API (OpenRouter)
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

      const aiResponse = aiRes.data.choices[0].message.content;

      // 3. Write the answer back to the Firestore document
      await admin.firestore().collection("queries").doc(queryId).update({
        aiResponse: aiResponse,
        status: "completed",
      });

      console.log("Successfully answered query.");
      
    } catch (error) {
      console.error("Error getting AI response:", error);
      // Write error back to Firestore so the app can see it
      await admin.firestore().collection("queries").doc(queryId).update({
        aiResponse: "Sorry, an error occurred. Please try again. \n\nمعذرت، ایک خرابی پیش آ گئی ہے۔ براہ مہربانی دوبارہ کوشش کریں.",
        status: "error",
      });
    }
  });