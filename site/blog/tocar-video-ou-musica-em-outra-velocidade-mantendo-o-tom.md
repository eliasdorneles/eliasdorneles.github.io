Title: Tocar vídeo ou música em outra velocidade mantendo o tom
Date: 2011-07-28 10:53
Author: Elias Dorneles

Alguns meses atrás descobri o [Play it slowly](http://29a.ch/playitslowly/
"http://29a.ch/playitslowly/"), um programa para tocar arquivos de áudio em
velocidades ou alturas diferentes, no Linux. Você pode usá-lo para, por
exemplo, ouvir uma música no mesmo tom da original mas com um ritmo bem mais
lento (útil para aprender as notas de um solo complicado), ou ainda ouvir um
*podcast* numa velocidade um pouco mais rápida sem transformar a voz do
palestrante na de um ratinho. (Tem um equivalente para Windows, [Best
Practice](http://bestpractice.sourceforge.net
"http://bestpractice.sourceforge.net"), grátis e livre assim como o Play it
slowly).

Frequentemente eu preciso fazer algo parecido, mas com um vídeo. A melhor
alternativa que encontrei, até agora, é utilizar o plugin
[scaletempo](http://scaletempo.sourceforge.net
"http://scaletempo.sourceforge.net") do [mplayer](http://www.mplayerhq.hu
"http://www.mplayerhq.hu") (nunca testei, mas acredito que também funcione no
Windows):

    mplayer -af scaletempo video.avi

Tendo iniciado o *mplayer* assim, basta usar os atalhos [ ou ] (abre e
fecha colchetes) para reduzir ou aumentar a velocidade, respectivamente!
Para o *mplayer* sempre carregar o plugin *scaletempo* para qualquer
arquivo, coloquei no meu *\~/.mplayer/config* a diretiva:

    af=scaletempo

Era isso! :)
