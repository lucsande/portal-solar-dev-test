const showModal = () => {
  const freightBtns = document.querySelectorAll('#freight-btn');
  freightBtns.forEach((freightBtn) => {
    const id = freightBtn.dataset.pgen;
    const hiddenPgenID = document.querySelector('#hidden-pgen-id');
    freightBtn.addEventListener('click', (event) => {
      event.preventDefault;

      $('#freightModal').modal('show');
      let freightMessage = document.querySelector(".freight-message");
      if (freightMessage) {
        freightMessage.remove();
      }


      hiddenPgenID.value = id
    });
  });
}

export { showModal };
