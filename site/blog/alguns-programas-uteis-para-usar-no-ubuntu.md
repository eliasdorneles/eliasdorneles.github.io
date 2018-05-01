Title: Alguns programas úteis para usar no Ubuntu
Date: 2013-08-14 22:24
Author: Elias Dorneles
Slug: Alguns-programas-úteis-para-usar-no-Ubuntu

Ok, hoje estou tirando a preguiça do traseiro para escrever sobre algo
que há tempo queria fazer: uma lista de alguns programas úteis que uso
no [Ubuntu](http://www.ubuntu.com/ "Ubuntu Linux"). A maioria deles eu
demorei um pouco para descobri-los, por isso acho uma boa idéia falar
deles por aqui -- são aplicações bacanas que merecem uma boa propaganda.

### Meld

[Meld](http://meldmerge.org/) é uma ferramenta muito útil para
programadores, mas que pode muito bem ser útil para outras pessoas
também. Ele ajuda você a ver as diferenças entre versões diferentes de
arquivos ou pastas, e permite copiar as coisas de um lado para outro e
vice-versa.

Comparando duas pastas com o Meld:

[![Comparando duas pastas com o Meld](https://eljunior.files.wordpress.com/2013/08/minha_pasta-outra_pasta-meld_004.png "Comparando duas pastas com o Meld")](https://eljunior.files.wordpress.com/2013/08/minha_pasta-outra_pasta-meld_004.png)

Ele é uma mão-na-roda para o desenvolvedor na hora de fazer
*[merges](http://en.wikipedia.org/wiki/Merge_(revision_control) "Artigo sobre merges na Wikipedia")*
complicados, e também para verificar a situação de projetos que foram
alterados por pessoas diferentes sem usar um sistema de controle de
versão decente (que aliás, se a escolha estiver em aberto pra você ou
caso ainda esteja usando CVS/SVN, recomendo dar uma boa olhada no
[Mercurial](http://mercurial.selenic.com/) -- [pode começar por
aqui](http://hginit.com/)).

Para instalar no Ubuntu, digite num terminal:

`sudo apt-get install meld`

> **Dica:** um jeito rápido de copiar e colar linhas de comando do
> navegador no terminal é dar um triplo-clique (clicar 3x) em qualquer
> lugar da linha pra selecioná-la inteira, e depois clicar no terminal
> com o botão do meio (isto é, com a rodinha do mouse) -- isto já copia
> e cola incluindo até o <kbd>Enter</kbd>. É o "copiar e colar" mais
> tradicional do Linux, pra mim é meio surpreendente como muitos
> *power-users* desconhecem esse truque.


### Shutter

[Shutter](http://shutter-project.org/) é um programa que ajuda a fazer
capturas da tela, aka, *screenshots*. A maioria das pessoas está
acostumada a fazer esse tipo de coisa usando a tecla <kbd>Print
Screen</kbd>, mas o legal do Shutter é que você pode escolher um pedaço
específico da tela pra capturar, fazer alterações por cima, tudo no
mesmo passo.

[![Yo dawg, I heard you like taking screenshots!](https://eljunior.files.wordpress.com/2013/08/shutter-yo_dawg.png?w=640)](https://eljunior.files.wordpress.com/2013/08/shutter-yo_dawg.png)

Ele também tem plugins para aplicar efeitos nas imagens, fazer upload
para ImgUr, TwitPic, ImageShack, Dropbox, etc.

Pra instalar no Ubuntu, digite num terminal:

`sudo apt-get install shutter`

### DBeaver

O [DBeaver](http://jkiss.org/) é uma aplicação cliente de banco de dados
SQL, que suporta vários bancos e plataformas. Não é muito espetacular,
mas de todas as aplicações open-source desse tipo que testei, é de longe
a que tem a melhor usabilidade. Ele baixa os *drivers* adequados para
conectar nos vários bancos diferentes, só esse recurso já é uma bela
duma ajuda.

Pra instalar no Ubuntu, você pode escolher entre baixar e instalar o
pacote Debian ou baixar e descompactar o zip do site
[http://dbeaver.jkiss.org/download](http://dbeaver.jkiss.org/download/) -- ou
ainda, você também pode [instalar como
plugin](http://marketplace.eclipse.org/node/507775) para o
[Eclipse](http://www.eclipse.org/) se preferir.

### PlayItSlowly

O [PlayItSlowly](http://29a.ch/playitslowly/) é um programa muito legal
que permite reproduzir arquivos de áudio ou vídeo em velocidade e
frequência diferentes do áudio/vídeo original, até [já andei falando
antes sobre ele por
aqui](http://eljunior.wordpress.com/2011/07/28/tocar-video-ou-musica-em-outra-velocidade-mantendo-o-tom/).

  [![Can you guess from which band is this song?](https://eljunior.files.wordpress.com/2013/08/play-it-slowly_012.png)](https://eljunior.files.wordpress.com/2013/08/play-it-slowly_012.png)

Usando o PlayItSlowly você pode fazer andar mais rápido o vídeo daquela
palestra lenta que dá sono e também ouvir um trecho duma música
repetindo em velocidade mais lenta sem perder o tom original, pra você
poder perceber melhor as notas -- bem útil pra quem quer aprender a
tocar alguma música. Além disso, você também pode sacanear seus amigos
reproduzindo uma gravação deles conversando com a fala fina... Esse
programa é muito bacana, especialmente porque eu tenho uma pequena
parcela de contribuição no quão legal ele é: a última versão dele inclui
algumas melhorias na interface que eu implementei. =)

Se você está usando a última versão do Ubuntu, pode instalar digitando
no terminal:

`sudo apt-get install playitslowly`

Caso esteja usando uma versão mais antiguinha, considere [baixar o
pacote com a última versão do site](http://29a.ch/playitslowly/) --
prometo que a interface melhora legal.

### Amphetype

  [![Amphetype: pratique digitação digitando e lendo seu texto preferido](https://eljunior.files.wordpress.com/2013/08/amphetype_001.png?w=640 "Tela inicial do Amphetype")](https://eljunior.files.wordpress.com/2013/08/amphetype_001.png)

[Amphetype](http://code.google.com/p/amphetype/) é um programa pra treinar
digitação com textos que você escolhe, que também gera umas estatísticas
joiadas. Infelizmente, não está mais sendo mantido e acho que nunca teve um
empacotamento de verdade pra Linux ([só tem instalador para Windows e
Mac](https://code.google.com/p/amphetype/downloads/list "Instaladores do
Amphetype para Windows e Mac")).  Mesmo assim, continua sendo bem decente -- eu
uso uma versão que modifiquei levemente para facilitar a deleção dos textos
fontes. Um dia quem sabe eu tomo vergonha na cara e tento montar um pacote,
publicar o *patch*, etc.

Como falei, não tem um empacotamento pronto pra Linux, mas você consegue
rodar baixando o código-fonte, usando alguns comandos no terminal:

1.  Instale o subversion para poder baixar os fontes:  
   `sudo apt-get install subversion`
2.  Use o subversion para baixar os fontes:  
   `svn checkout http://amphetype.googlecode.com/svn/trunk/ amphetype-read-only`
3.  Execute o programa com o comando:  
   `python Amphetype.py`

### Pinta

O Pinta é um programa muito bem feitinho, pra editar imagens no estilo
do MS Paint -- uma coisa que demorou um pouquinho pra aparecer no Linux.
Um recurso legal dele é o *“Recolor”*, que pinta apenas em cima de uma
determinada cor. Funciona como aquelas canetas marca-texto, permitindo
chamar atenção para textos em outras imagens como nesse exemplo:

  [![É divertido pintar com o Pinta =)](https://eljunior.files.wordpress.com/2013/08/diffusionofinnovation-pinta_003.png?w=640)](https://eljunior.files.wordpress.com/2013/08/diffusionofinnovation-pinta_003.png)
  É divertido pintar com o Pinta =)

Instale no Ubuntu digitando num terminal:

`sudo apt-get install pinta`

### Programas para usar na linha de comando

Além desses programas, gostaria ainda de falar rapidão de outros
programas úteis pra quem também gosta de usar a linha de comando:

-   [quilt](http://en.wikipedia.org/wiki/Quilt_(software)) é um conjunto
    de shell-scripts que ajudam a lidar com diffes e patches, é uma
    ótima ferramenta para um desenvolvedor ter na sua caixa, já me foi
    útil várias vezes. Instale com:  
   `sudo apt-get install quilt`
-   [rlwrap](http://utopia.knoware.nl/~hlub/rlwrap/) é um programa que
    adiciona os recursos da linha de comando de histórico e atalhos de
    edição, em qualquer outro programa que leia comandos da entrada
    padrão (Teste com `rlwrap ruby`, por exemplo). Instale com:  
   `sudo apt-get install rlwrap`
-   [tree](http://stackoverflow.com/questions/3455625/linux-command-to-print-directory-structure-in-the-form-of-a-tree)
    é um programa bem simples, que lista os diretórios em forma de
    árvore. Por algum motivo, levei anos pra descobrir que esse programa
    existia. Instale com:  
   `sudo apt-get install tree`
