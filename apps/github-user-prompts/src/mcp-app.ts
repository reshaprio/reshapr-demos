import { App } from "@modelcontextprotocol/ext-apps";

// ── Prompt definitions (matching the Prompts YAML) ──
const PROMPTS: Record<string, { title: string; result: string }> = {
  get_user_profile_with_followers: {
    title: "User Profile & Followers",
    result:
      "Get the profile details and latest followers for the GitHub user '${user}'.\n" +
      "The MCP tool to call is 'get_user_with_latest_followers', using '${user}' as the tool argument called 'user'.",
  },
  who_follows_user: {
    title: "Who Followed Recently?",
    result:
      "List the most recent followers of the GitHub user '${user}' with their avatar and profile details.\n" +
      "The MCP tool to call is 'get_user_with_latest_followers', using '${user}' as the tool argument called 'user'.\n" +
      "Focus the response on the followers information.",
  },
  compare_user_followers: {
    title: "Popularity Snapshot",
    result:
      "Get the profile and latest followers for the GitHub user '${user}' to provide a popularity snapshot.\n" +
      "The MCP tool to call is 'get_user_with_latest_followers', using '${user}' as the tool argument called 'user'.\n" +
      "Summarize the user's profile and highlight who has recently followed them.",
  },
};

const goBtn = document.getElementById("go-btn") as HTMLButtonElement;
const userInput = document.getElementById("user-input") as HTMLInputElement;
const promptCards = document.querySelectorAll<HTMLButtonElement>(".prompt-card");
const activePromptBadge = document.getElementById("active-prompt-badge")!;
const activePromptLabel = document.getElementById("active-prompt-label")!;
const activePromptText = document.getElementById("active-prompt-text")!;

// ── App instance — create early and set handlers before connect() ──
const app = new App({ name: "GitHub-User App", version: "1.0.0" });

// ── Prompt card selection ──
let selectedPrompt: string | null = null;

promptCards.forEach((card) => {
  card.addEventListener("click", () => {
    promptCards.forEach((c) => c.classList.remove("selected"));
    card.classList.add("selected");
    selectedPrompt = card.dataset.prompt ?? null;
    updateGoButton();
  });
});

promptCards[0]?.click();

userInput.addEventListener("input", updateGoButton);
userInput.addEventListener("keydown", (e) => {
  if (e.key === "Enter" && !goBtn.disabled) submitPrompt();
});

goBtn.addEventListener("click", submitPrompt);

function updateGoButton() {
  goBtn.disabled = !selectedPrompt || !userInput.value.trim();
}

function submitPrompt() {
  const user = userInput.value.trim();
  if (!selectedPrompt || !user) return;

  const prompt = PROMPTS[selectedPrompt];
  if (!prompt) return;

  goBtn.disabled = true;

  activePromptLabel.textContent = prompt.title;
  activePromptText.textContent = prompt.result.replace(/\$\{user\}/g, user);
  activePromptBadge.classList.add("visible");

  // Interpolate the prompt result text with the user value and send to chat
  const messageText = prompt.result.replace(/\$\{user\}/g, user);
  app.sendMessage({
    role: "user",
    content: [{ type: "text", text: messageText }],
  }).then((result) => {
    console.log("[mcp-app] sendMessage result:", result);
    if (result.isError) {
      console.error("[mcp-app] sendMessage rejected by host");
      updateGoButton();
      return;
    }
    userInput.value = "";
    updateGoButton();
  }).catch((err) => {
    console.error("[mcp-app] sendMessage error:", err);
    updateGoButton();
  });
}

// Connect to host
app.connect();
