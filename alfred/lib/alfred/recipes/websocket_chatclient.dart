// TODO it would be great if the javascript portion could come from a dart file that was dart2js'ed
// TODO use mela to be typesafe.
const String websocket_chatclient = r"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>WebSocket</title>
    <style>
        body {font-family: sans-serif;}
        #messages {background: #d8edf5; border-radius: 8px; min-height: 100px; margin-bottom: 8px; display: flex; flex-direction: column;}
        #messages div {background: #eff6f8; border-radius: 8px;  margin: 8px; padding: 6px 12px; display: inline-block; width: fit-content}
    </style>
</head>
<body>
<div id="messages"></div>
<div class="panel">
    <label>Type message and hit <i>&lt;Enter&gt;</i>: <input autofocus id="input" type="text"></label>
</div>
<script type="module">
    document.addEventListener('DOMContentLoaded', () => {
        const input = document.querySelector('#input');
        const messages = document.querySelector('#messages');
        const socket = new WebSocket(`ws://${location.host}/ws`);
        socket.onopen = () => {
            console.log('WebSocket connection established.');
        }
        socket.onmessage = (e) => {
            const el = document.createElement('div');
            el.innerText = e.data;
            messages.appendChild(el);
        }
        socket.onclose = () => {
            console.log('WebSocket connection closed');
        }
        socket.onerror = () => {
            location.reload();
        }
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && input.value.length > 0) {
                socket.send(input.value);
                input.value = '';
            }
        });
    })
</script>
</body>
</html>
""";
