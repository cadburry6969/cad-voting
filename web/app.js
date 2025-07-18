let selectedParty = null;

const createParty = (party) => {
    const card = document.createElement('div');
    card.classList.add('candidate-card');
    card.setAttribute('id', party.id);
    card.innerHTML = `
        <img class="candidate-logo" src="${party.logo}" alt="image"/>
        <p class="candidate-name">${party.name}</p>
        <p class="candidate-party">${party.party}</p>`;

    card.addEventListener('click', () => {
        if (selectedParty) selectedParty.classList.remove('selected');
        selectedParty = card;
        card.classList.add('selected');
    });
    return card;
}

const setSettings = (settings) => {
    if (!settings) return;
    document.getElementById('voting:title').innerText = settings.title;
    document.getElementById('voting:tagline').innerText = settings.tagline;
}

const openUI = (data) => {
    if (data.settings) setSettings(data.settings);
    let container = document.querySelector('#candidates-list');
    container.innerHTML = '';
    if (data.parties) {
        Object.entries(data.parties).forEach(party => {
            if (party && party[1]) {
                const card = createParty(party[1]);
                container.appendChild(card);    
            }
        });
    }
    $('.voting-wrapper').fadeIn(280);
    $('.voting-wrapper').css('display', 'grid');
}

const closeUI = () => {
    $('.voting-wrapper').fadeOut(280);
    $.post(`https://${GetParentResourceName()}/closeUI`)
}

$('.close-btn').on('click', () => closeUI());

document.addEventListener('keyup', (e) => {
    if (e.keyCode === 27) {
        closeUI();
    }
});

const castVote = () => {
    if (selectedParty) {
        const partyId = selectedParty.getAttribute('id');
        $.post(`https://${GetParentResourceName()}/castVote`, JSON.stringify({ partyId: partyId }))
        closeUI();
    }
}

$('.submit-btn').on('click', () => castVote());

window.addEventListener("message", (event) => {
    const eventData = event.data;
    switch (eventData.action) {
        case "showUI":
            return openUI(event.data.data);
        case "closeUI":
            return closeUI();
        default:
            return;
    }
});
