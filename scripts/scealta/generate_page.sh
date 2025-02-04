#!/usr/bin/env bash

if [[ $1  == '' || $2 == '' || $3 == '' ]]; then
    echo "Expected '$0 <resources/downloaded_file_name.tsv> <title> <page_name> <background_image_url>'"
    exit 1
fi

mkdir "../../client/scealta/$3"
echo "Source File: $1"
echo "Page Title: $2"
echo "Page Name: $3"
echo "Background Image: $4"

python3 generate_page_utils.py $1 $3

BACKGROUND_IMAGE=""
FILE_EXTENSION=$(echo "$url" | sed 's:.*\.::')
curl -o "../../client/scealta/$3/background.${FILE_EXTENSION}" -L $url && \
BACKGROUND_IMAGE="background: url('background.${FILE_EXTENSION}') no-repeat center center fixed;"

cat << EOF > ../../client/scealta/$3/index.html
<!DOCTYPE html>
<html lang="ie">
<head>
   <title>$2</title>
   <meta charset="UTF-8">
   <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
   <meta name="viewport" content="width=device-width,minimum-scale=1,maximum-scale=1">
   <link href="/client/assets/custom-styling.css" rel="stylesheet">
   <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">

   <style>
       body {
           background-color: #dae0e5;
           $BACKGROUND_IMAGE
           -webkit-background-size: 100% 100%;
           -moz-background-size: 100% 100%;
           -o-background-size: 100% 100%;
           background-size: 100% 100%;
       }
   </style>
   <!-- Global site tag (gtag.js) - Google Analytics -->
   <script async src="https://www.googletagmanager.com/gtag/js?id=UA-160761764-1"></script>
   <script>
       window.dataLayer = window.dataLayer || [];
       function gtag(){dataLayer.push(arguments);}
       gtag('js', new Date());

       gtag('config', 'UA-160761764-1');
   </script>
</head>
<body>
<header>
   <nav class="navbar navbar-expand-md navbar-light fixed-top bg-light border-bottom shadow-sm">
       <a class="navbar-brand" href="/">
           <img src="/client/assets/images/controller.svg" alt="Controller icon" width="36" height="36" title="Baile"/>
           Cluichí as Gaeilge
       </a>
       <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
           <span class="navbar-toggler-icon"></span>
       </button>
       <div class="collapse navbar-collapse justify-content-end" id="navbarCollapse">
           <a class="p-2 ml-2 btn btn-light" href="/boggle">Boggle</a>
           <a class="p-2 ml-2 btn btn-light" href="/ris">Rís</a>
           <a class="p-2 ml-2 btn btn-light disabled" href="/risk">Éire Aontaithe (Risk)</a>
           <a class="p-2 ml-2 btn btn-light active" href="/scealta">Scéalta</a>
           <a class="p-2 ml-2 btn btn-outline-primary" href="/eolas">Eolas</a>
       </div>
   </nav>
</header>
<main role="main" class="container">
   <h2 style="text-align: center; background-color: #dae0e5; border-radius: 5px;" class="p-2">$2</h2>
   <div class="row pb-3 pt-5 px-5 my-5 mx-1 card">
       <div class="col-10 offset-1">
           <h3 id="teideal" style="text-align: center"></h3>
           <p id="teacs" style="text-align: justify"></p>
       </div>
       <div class="mt-3" id="choices"></div>
   </div>
</main>
<footer class="footer" style="text-align: center;">
       <span class="text-muted">Suíomh cruthaithe ag: <a class="text-dark" target="_blank" href="https://soceanainn.com">
           Séamus Ó Ceanainn
       </a></span>
</footer>
</body>

<script src="sceal.js"></script>
<script>
   function displayParagraph(id){
       const paragraph = sceal[id];
       document.getElementById('teideal').innerText = paragraph.title;
       document.getElementById('teacs').innerText = paragraph.text;
       displayChoices(paragraph.choices);
       sessionStorage.setItem("alt", id);
   }

   function displayEnd(){
       let content = document.createElement('h2');
       content.innerText = "Críoch";
       content.style.textAlign = 'center';

       let div = document.createElement('div');
       div.className = "col-12 col-sm-6 offset-sm-3 mt-1 btn btn-primary";
       div.innerText = "Tosaigh arís?";
       div.setAttribute("onclick", "displayParagraph('0')");

       document.getElementById('choices').append(content);
       document.getElementById('choices').append(div);
   }
   function displayChoices(choices){
       document.getElementById('choices').innerHTML = "";
       if (choices.length === 0) displayEnd();
       else if (choices.length % 2 === 1) renderChoices(choices, 'offset-sm-3');
       else renderChoices(choices, '');
   }

   function renderChoices(choices, offset){
       let row = document.createElement('div');
       row.className = "row";
       document.getElementById('choices').append(row);
       for (const c in choices) {
           let div = document.createElement('div');
           div.className = "col-12 col-sm-6 p-2 btn btn-outline-primary";
           if (c === "" + (choices.length - 1)) div.className += " " + offset;
           div.innerText = choices[c].text;
           div.setAttribute("onclick", "displayParagraph(" + choices[c].goto + ")");
           row.append(div);
       }
   }

   let myParam = sessionStorage.getItem('alt');
   if (myParam === null) myParam = "0";
   displayParagraph(myParam);
</script>

<script src="https://code.jquery.com/jquery-3.4.1.slim.min.js" integrity="sha256-pasqAKBDmFT4eHoN2ndd6lN370kFiGUFyTiUHWhU7k8=" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.bundle.min.js" integrity="sha384-6khuMg9gaYr5AxOqhkVIODVIvm9ynTT5J4V1cfthmT+emCG6yVmEZsRHdxlotUnm" crossorigin="anonymous"></script>
</html>
EOF