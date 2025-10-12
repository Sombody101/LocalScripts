#!/bin/bash
# Site tools

regload "$ST"

newsite() {

#
#   index.html
#

    echo -ne '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="/index.css">
    <script src="/extras/pre-runner.js"></script>
    <title>Website</title>
</head>
<body>
    
    <script src="/index.js"></script>
</body>
</html>
' >index.html

#
#   index.css
#

    echo -ne '@import url("https://fonts.googleapis.com/css2?family=Source+Code+Pro:wght@200&display=swap");

*,
*::after,
*::before {
    /* For debugging
    border: 1px dotted red;
    */
    --_: none;

    box-sizing: border-box;
    font-family: "Source Code Pro", Arial, Helvetica, sans-serif;
}

:root {
    --font-size-sm: clamp(0.8rem, 0.17vw + 0.76rem, 0.89rem);
    --font-size-base: clamp(1rem, 0.34vw + 0.91rem, 1.19rem);
    --font-size-md: clamp(1.25rem, 0.61vw + 1.1rem, 1.58rem);
    --font-size-lg: clamp(1.56rem, 1vw + 1.31rem, 2.11rem);
    --font-size-xl: clamp(1.95rem, 1.56vw + 1.56rem, 2.81rem);
    --font-size-xxl: clamp(2.44rem, 2.38vw + 1.85rem, 3.75rem);
    --font-size-xxxl: clamp(3.05rem, 3.54vw + 2.17rem, 5rem);

    --primary: rgb(0, 123, 255);
    --secondary: rgb(52, 152, 219);
    --neutral: rgb(204, 204, 204);
    --background: rgb(232, 232, 232);
    --accent: rgb(0, 149, 255);
    --text-color: rgb(0, 0, 0);
    --w-text-color: rgb(255, 255, 255);
    --b-text-color: rgb(0, 0, 0);

    --background-alt: rgb(0, 53, 156);
    --background-grad: linear-gradient(90deg, rgba(0, 53, 156, 1) 0%, rgba(0, 123, 255, 1) 100%);

    --pfp-size: 17vh;

    --font-title: "Source Code Pro", monospace;

    /* "Text" based variables */
    --T-primary: none;
    --T-secondary: none;
    --T-neutral: none;
    --T-background: none;
    --T-accent: none;
    --T-text-color: none;
}

#DARK_PREVIEW {
    --NAN-primary-dark: rgb(0, 86, 179);
    --NAN-secondary-dark: rgb(0, 47, 94);
    --NAN-neutral-dark: rgb(170, 170, 170);
    --NAN-background-dark: rgb(20, 20, 20);
    --NAN-accent-dark: rgb(255, 215, 0);
}

h1 {
    font-size: var(--font-size-xxl);
}

h2 {
    font-size: var(--font-size-xxl);
}

h3 {
    font-size: var(--font-size-xl);
}

h4 {
    font-size: var(--font-size-lg);
}

h5 {
    font-size: var(--font-size-mg);
}

p {
    font-family: var(--font-title);
    font-size: var(--font-size-base);
    transition: font-size 0.3s ease;
}

header {
    transition: transform 0.3s ease-in-out;
    background-color: var(--background);
    align-items: center;
    display: flex;
    z-index: 100;
    height: 50px;
    width: 100%;
    padding: 10px;
    position: fixed;
    border-radius: 0 0 10px 10px;
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.2);
}

.nav-up {
    transform: translateY(-100px);
}

html,
body {
    background-color: var(--background);
    color: var(--text-color);
    margin: 0;
    height: 100vh;
    display: grid;
    grid-template-rows: auto 1fr;
}

.title {
    font-family: var(--font-title);
    color: var(--text-color);
    font-size: 48px;
    font-weight: 200;
    word-wrap: normal;
    transition: font-size 0.3s ease;
}

.display-box {
    background: rgba(var(--T-neutral), .2);
    padding: 30px;
    margin: 30vh 10px;
    border-radius: 10px;
    font-family: var(--font-title);
    font-weight: 400;
    transition: margin 0.5s ease;
}

@media screen and (max-width: 650px) {
    .title {
        font-size: 24px;
    }

    .sub-title {
        font-size: 12px;
    }

    .display-box {
        margin: 30vh 0;
    }

    .lucky-message {
        font-size: 8px;
    }
}

main {
    margin: 10px 20%;
    padding: 10px;
}

footer {
    border-radius: 10px 10px 0 0;
    background-color: var(--primary);
    color: var(--text-color);
    padding: 10px;
    text-align: center;
    margin: auto 8px;
}

.centered {
    justify-content: center;
    justify-self: center;
    text-align: center;
}

.left {
    padding: 20px;
}

.right {
    padding: 20px;
    margin-left: auto;
}

' >index.css

#
#   index.js
#

    echo -ne "const DEBUG = true" >index.js

    mkdir assets
    mkdir extras

#
#   pre-runner.js
#

    echo -ne "
" >extras/pre-runner.js
}
