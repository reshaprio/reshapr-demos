import { App } from "@modelcontextprotocol/ext-apps";

// Get element references
const nameEl = document.getElementById("name")!;
const usernameEl = document.getElementById("username")!;
const bioEl = document.getElementById("bio")!;
const locationEl = document.getElementById("location")!;
const blogEl = document.getElementById("blog")!;
const avatarEl = document.getElementById("avatar") as HTMLImageElement;
const followersEl = document.getElementById("followers")!;

// Create app instance
const app = new App({ name: "GitHub-User App", version: "1.0.0" });

// Handle tool results from the server. Set before `app.connect()` to avoid
// missing the initial tool result.
app.ontoolresult = (result) => {
  const textContent = result.content?.find((c) => c.type === "text")?.text;
  const data = textContent ? JSON.parse(textContent).data : null;

  nameEl.textContent = data?.user.name ?? "[ERROR]";
  usernameEl.textContent = data?.user.login ? '@' + data.user.login : "[ERROR]";
  bioEl.textContent = data?.user.bio ?? "[ERROR]";
  locationEl.textContent = data?.user.location ?? "[ERROR]";
  blogEl.textContent = data?.user.websiteUrl ?? "[ERROR]";

  avatarEl.src = data?.user.avatarUrl ?? "https://avatars.githubusercontent.com/u/1?v=4";

  if (data?.user.followers.nodes) {
    let followersList = '';
    data.user.followers.nodes.forEach((follower: any) => {
      followersList += `<a href="https://github.com/${follower.login}">${follower.login}</a> `;
    });
    followersEl.innerHTML = followersList;
  }
};


// Connect to host
app.connect();
