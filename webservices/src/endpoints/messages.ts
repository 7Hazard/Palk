import { jsonResponse } from "../helpers";
import { Endpoint } from "../interfaces/Endpoint";

export const messages: Endpoint[] = [
    {
        method: "POST", path: "/messages", handler: async req => {
            let json = await req.json<{
                chat: string
            }>()
            return jsonResponse(json)
        }
    }
]
