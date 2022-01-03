import { messages } from "./endpoints/messages";
import { jsonResponse } from "./helpers";
import { Endpoint } from "./interfaces/Endpoint";

const apiPathPrefix = "/api/v1"

let endpoints: Endpoint[] = [
  { method: "GET", path: "/", handler: async _ => jsonResponse(endpoints.map(endpoint => endpoint.path.replace(apiPathPrefix, ""))) },
  ...messages
]

for (const endpoint of endpoints) {
  endpoint.path = apiPathPrefix + endpoint.path
}

addEventListener("fetch", (event) => {
  event.respondWith(
    handleRequest(event.request).catch(
      (err) => new Response(err.stack, { status: 500 })
    )
  );
});

/**
 * Many more examples available at:
 *   https://developers.cloudflare.com/workers/examples
 * @param {Request} request
 * @returns {Promise<Response>}
 */
async function handleRequest(request: Request) {
  const { pathname } = new URL(request.url);

  for (const endpoint of endpoints) {
    if (endpoint.method != request.method && endpoint.path != pathname) continue
    return endpoint.handler(request)
  }

  return new Response(null, { status: 404 })

  // if (pathname.startsWith("/api")) {
  //   return new Response(JSON.stringify({ pathname }), {
  //     headers: { "Content-Type": "application/json" },
  //   });
  // }

  // if (pathname.startsWith("/status")) {
  //   const httpStatusCode = Number(pathname.split("/")[2]);

  //   return Number.isInteger(httpStatusCode)
  //     ? fetch("https://http.cat/" + httpStatusCode)
  //     : new Response("That's not a valid HTTP status code.");
  // }

  // return fetch("https://welcome.developers.workers.dev");
}
