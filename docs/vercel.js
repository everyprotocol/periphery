(function () {
  // Insert inline script
  const inlineScript = document.createElement("script");
  inlineScript.text = `
    window.va = window.va || function () {
      (window.vaq = window.vaq || []).push(arguments);
    };
  `;
  document.body.appendChild(inlineScript);

  // Insert external script
  const externalScript = document.createElement("script");
  externalScript.src = "/_vercel/insights/script.js";
  externalScript.defer = true;
  document.body.appendChild(externalScript);
})();
