
export interface Endpoint {
    method: "GET" | "POST" | "PUT" | "DELETE"
    path: string
    handler: (request: Request) => Promise<Response>
}
