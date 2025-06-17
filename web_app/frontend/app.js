async function uploadImage() {
  const input = document.getElementById('imageInput');
  const file = input.files[0];
  const preview = document.getElementById('preview');

  if (!file) {
    preview.innerHTML = `<p style="color:red;">Please select a file first.</p>`;
    return;
  }

  const formData = new FormData();
  formData.append('image', file);

  try {
    const response = await fetch('http://localhost:4000/upload', {
      method: 'POST',
      body: formData
    });

    const resultText = await response.text();
    preview.innerHTML = `<p>${resultText}</p>`;
  } catch (error) {
    preview.innerHTML = `<p style="color:red;">Upload failed. ${error}</p>`;
  }
}
