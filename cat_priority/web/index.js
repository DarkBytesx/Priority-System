
const CreateStatus = (type, name, cooldown, input, location) => {
    console.log("Creating status:", type, name, cooldown, location); // Log for debugging

    // Remove previous status elements
    $(`#hold`).remove();
    $(`#inprogress`).remove();
    $(`#safe`).remove();
    $("#cooldown").remove();

    let html;
    if (type === 'hold') {
        html = `
            <div class="status" id=${type}>
                <p><span style='color:rgb(6, 137, 244)'>🟦 HOLD</span> (${name})</p>
            </div>
        `;
    } else if (type === 'inprogress') {
        html = `
            <div class="status" id=${type}>
                <p><span style='color:rgb(237, 0, 0)'>🟥 IN PROGRESS</span> (${name})</p>
                ${location ? `<p>Location: ${location}</p>` : ""}
            </div>
        `;
    } else if (type === 'safe') {
        html = `
            <div class="status" id=${type}>
                <p><span style='color:rgb(23, 209, 42)'>🟩 SAFE</span> (${name})</p>
            </div>
        `;
    } else if (type === 'cooldown' || type === 'reset') {
        html = `
            <div class="status" id="cooldown">
                <p><span style='color:rgb(255, 0, 0)'>🕜 ${cooldown}</span> SECONDS (${name})</p>
            </div>
        `;
    }
    $('.prioBody').append(html);
}


$(function() {
    window.onload = (e) => {
        window.addEventListener('message', (event) => {
            console.log("Received message:", event.data);  // Log the incoming message

            switch (event.data.type) {
                case 'hold':
                    CreateStatus(event.data.type, event.data.name);
                    break;
                case 'inprogress':
                    CreateStatus(event.data.type, event.data.name, event.data.cooldown, event.data.input);
                    break;
                case 'safe':
                    CreateStatus(event.data.type, event.data.name);
                    break;
                case 'cooldown':
                    CreateStatus(event.data.type, event.data.name, event.data.cooldown);
                    break;
                case 'reset':
                    CreateStatus(event.data.type, event.data.name, event.data.cooldown);
                    break;
                case 'display':
                    if (event.data.display) {
                        $('.prioBody').show();  // Show NUI
                    } else {
                        $('.prioBody').hide();  // Hide NUI
                    }
                    break;
                default:
                    console.error("Unknown event type:", event.data.type);
            }
        });
    };
});

// Inform the Lua script that the NUI is ready
document.addEventListener("DOMContentLoaded", () => {
    fetch("https://priority/nuiReady2", {
        method: "POST",
    })
   .catch((e) => console.error("Unable to send NUI ready message", e));
});
