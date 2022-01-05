import { jsonResponse } from "../helpers";
import { Endpoint } from "../interfaces/Endpoint";

export const messages: Endpoint[] = [
    {
        method: "POST", path: "/messages", handler: async req => {
            let json = await req.json<{
                chat: string,
                data: string,
            }>()

            var headers = new Headers();
            headers.append("Authorization", `key=${FCM_KEY}`);
            headers.append("Content-Type", "application/json");

            var raw = JSON.stringify({
                "to": `/topics/${json.chat}`,
                "notification": {
                    "title": "-",
                    "body": "-",
                    "sound": "default"
                },
                "data": {
                    "kind": "message",
                    "chat": json.chat,
                    "data": json.data
                },
                "content_available": true,
                "priority": "high",
                "mutable_content": true
            });

            var requestOptions = {
                method: 'POST',
                headers: headers,
                body: raw,
                redirect: 'follow'
            };

            let response = await fetch("https://fcm.googleapis.com/fcm/send", requestOptions)
            // .then(response => response.text())
            // .then(result => console.log(result))
            // .catch(error => console.log('error', error));

            if(response.status != 200) return new Response(null, {status: 500})

            const jsonresp = await response.json<{ failure: number }>()
            if(jsonresp.failure == 1) return new Response(null, {status: 500})

            return jsonResponse(jsonresp)
        }
    }
]
