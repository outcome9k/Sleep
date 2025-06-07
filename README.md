<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Run Sleep Script</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #111;
      color: #eee;
      padding: 20px;
    }
    pre {
      background: #222;
      padding: 10px;
      border-radius: 8px;
      overflow-x: auto;
    }
    button {
      background-color: #0f62fe;
      color: white;
      padding: 6px 12px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      margin-top: 5px;
    }
    button:hover {
      background-color: #0353e9;
    }
  </style>
</head>
<body>

<h2>🚀 How to Run Sleep Script</h2>

<pre>
<code id="code1">bash &lt;(curl -fsSL https://raw.githubusercontent.com/outcome9k/Sleep/main/slop.sh)</code>
</pre>
<button onclick="copyToClipboard('code1')">📋 Copy</button>

<h2>🌀 Alternative Run</h2>

<pre>
<code id="code2">bash &lt;(curl -s https://raw.githubusercontent.com/outcome9k/Sleep/main/slopp.sh)</code>
</pre>
<button onclick="copyToClipboard('code2')">📋 Copy</button>

<script>
function copyToClipboard(id) {
  const text = document.getElementById(id).textContent;
  navigator.clipboard.writeText(text).then(() => {
    alert("✅ Copied to clipboard!");
  }, () => {
    alert("❌ Failed to copy.");
  });
}
</script>

</body>
</html>
