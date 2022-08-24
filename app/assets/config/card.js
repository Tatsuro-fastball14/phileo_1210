cardElement.on('change', (e) => {
  document.querySelector('#brand').innerText = e.brand
  document.querySelector('#empty').innerText = e.empty
  document.querySelector('#complete').innerText = e.complete
  document.querySelector('#error').innerText = JSON.stringify(e.error)
})