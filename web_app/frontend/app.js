async function uploadImage() {
  const input = document.getElementById('imageInput');
  const file = input.files[0];
  const formData = new FormData();
  formData.append('image', file);

  const response = await fetch('http://YOUR-BACKEND-LOADBALANCER-URL/upload', {
    method: 'POST',
    body: formData
  });

  const data = await response.json();
  const preview = document.getElementById('preview');
  preview.innerHTML = `<img src="${data.url}" width="300"><p>${data.message}</p>`;
}
