(function() {
  document.addEventListener('DOMContentLoaded', async () => {
    try {
      const response = await fetch('/api/');
      const data = await response.json();
      console.log(data);

      document.body.textContent = JSON.stringify(data, null, '  ');
    } catch (error) {
      console.error(error);

      document.body.textContent = error.stack;
    }
  });
})();
