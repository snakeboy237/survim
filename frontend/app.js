const uploadBtn = document.getElementById('uploadBtn');
const imageInput = document.getElementById('imageInput');
const preview = document.getElementById('preview');
const result = document.getElementById('result');

imageInput.addEventListener('change', function () {
    const file = imageInput.files[0];
    if (file) {
        preview.src = URL.createObjectURL(file);
        preview.style.display = 'block';
    }
});

uploadBtn.addEventListener('click', async function () {
    const file = imageInput.files[0];
    if (!file) {
        alert('Please select an image first!');
        return;
    }

    const formData = new FormData();
    formData.append('image', file);

    try {
        const response = await fetch('/api/upload', {
            method: 'POST',
            body: formData
        });

        const data = await response.json();
        result.textContent = JSON.stringify(data, null, 2);
    } catch (err) {
        console.error('Error uploading image:', err);
        result.textContent = 'Error uploading image!';
    }
});
