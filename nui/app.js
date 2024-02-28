let data = [];
let selectedCandidate = null;

const createCandidate = (candidate) => {
    const card = document.createElement("div");
    card.classList.add("candidate-card");
    card.setAttribute("id", candidate.id);
    card.innerHTML = `
        <img class="candidate-logo" src="${candidate.logo}" alt="image"/>
        <p class="candidate-name">${candidate.name}</p>
        <p class="candidate-party">${candidate.party}</p>`;

    card.addEventListener("click", () => {
        if (selectedCandidate) {
            selectedCandidate.classList.remove("selected");
        }
        selectedCandidate = card;
        card.classList.add("selected");
    });
    return card;
};

const renderCandidates = () => {
    let container = document.querySelector("#candidates-list");
    container.innerHTML = "";
    Object.keys(data).forEach(function (key) {
        const card = createCandidate(data[key]);
        container.appendChild(card);
    });
};

const openUI = () => {
    renderCandidates();
    $(".voting-wrapper").fadeIn(280);
    $(".voting-wrapper").css("display", "grid");
};

const closeUI = () => {
    $(".voting-wrapper").fadeOut(280);
    $.post(`https://${GetParentResourceName()}/close`);
};

$(".close-btn").on("click", () => {
    closeUI();
});

document.addEventListener("keyup", (e) => {
    if (e.keyCode === 27) {
        closeUI();
    }
});

const castVote = () => {
    if (selectedCandidate) {
        const id = selectedCandidate.getAttribute("id");
        $.post(
            `https://${GetParentResourceName()}/submit`,
            JSON.stringify({ id: id })
        );
        closeUI();
    }
};

$(".submit-btn").on("click", () => castVote());

window.addEventListener("message", (event) => {
    const eventData = event.data;
    switch (eventData.action) {
        case "showUI":
            data = event.data.data;
            return openUI();
        case "closeUI":
            return closeUI();
        default:
            return;
    }
});
