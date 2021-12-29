import { messages } from "./endpoints/messages";
import { Endpoint } from "./interfaces/Endpoint";

let endpoints: Endpoint[] = [
  { method: "GET", path: "/", handler: _ => new Response("Lets have a Palk!") },
  ...messages
]

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
    if (endpoint.method == request.method && endpoint.path != pathname) continue
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
