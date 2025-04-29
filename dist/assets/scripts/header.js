import { updateActiveLink } from "./navActive.js";
export async function loadHeader() {
  const host = document.getElementById("site-header");
  if (!host) throw new Error("#site-header is not found");
  const res = await fetch("assets/components/header.html");
  host.innerHTML = await res.text();
  updateActiveLink();
}
