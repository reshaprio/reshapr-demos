import express from "express";
import path from "node:path";

const app = express();
const port = parseInt(process.env.PORT ?? "3030", 10);
const distDir = path.join(process.cwd(), "dist");

app.use(express.static(distDir));

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});
