import { Endpoint } from "../interfaces/Endpoint";

export const messages: Endpoint[] = [
    {
        method: "POST", path: "/messages", handler: req => {
            return new Response("Ye wot?")
        }
    }
]
