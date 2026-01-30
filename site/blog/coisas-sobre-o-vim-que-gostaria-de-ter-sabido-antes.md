Title: Coisas sobre o VIM que gostaria de ter sabido antes
Date: 2013-04-07 15:41
Author: Elias Dorneles
Status: published

O [Vim](http://www.vim.org) ainda é o meu editor predileto. Tentei substituí-lo
várias vezes, e as únicas alternativas que chegaram perto de ameaçá-lo foram
[Emacs](http://www.gnu.org/software/emacs/) e [Sublime
Text](http://www.sublimetext.com): o primeiro pela quantidade de recursos, o
segundo pela interface joiada. Mas sempre que precisava resolver um problema
rapidão, acabava voltando pro [*good ol'*
Vim](http://arstechnica.com/information-technology/2011/11/two-decades-of-productivity-vims-20th-anniversary/
"Texto sobre os 20 anos de Vim").

> Ah, só antes de continuar, uma palavrinha para os perdidos: **Vim** não é o
> mesmo que **vi**, okay? Eu não suportaria usar o vi... :P

Mesmo que sempre gostasse do Vim, por um bom tempo me senti envergonhado por
continuar usando ele, pensando que nunca me esforçei de verdade em sair da zona
de conforto e usar outra coisa. Mas hoje, considerando que uso regularmente as
full-blown IDEs nos projetos Java - além de ter brincado bastante com Emacs e
ST2 --, se eu continuo voltando para o Vim, talvez não seja tanto assim por
falta de esforço meu pra sair da zona de conforto. Talvez seja porque ele seja
uma ferramenta que se encaixe bem no meu modo de pensar -- o meu *[user
model](http://www.joelonsoftware.com/uibook/fog0000000249.html)*. Talvez seja
porque ele é uma ferramenta [boa o
suficiente](https://en.wikipedia.org/wiki/Principle_of_good_enough) pra mim.
Talvez, em vez de sentir vergonha de usar uma ferramenta com aparência
antiquada, eu deveria valorizá-lo mais e melhorar o meu próprio uso dele.

Preferir o Vim não faz de mim um programador menos capaz - a não ser que eu
deixe de refatorar um código só porque meu editor não oferece as mesmas
facilidades duma IDE. (ahn, não quero falar dos programadores que amam sua IDE
mas nunca usam os recursos de refatoração...) Toda escolha envolve *tradeoffs*,
e o Vim certamente tem suas desvantagens, mas é uma escolha muito válida e pode
ser mesmo muito divertida.

Enfim, por isso que resolvi finalmente comprar o livro [Practical
Vim](http://pragprog.com/book/dnvim/practical-vim) do [Drew
Neil](http://vimcasts.org), que estou lendo (27%, me diz o Kindle) e curtindo
muito!

Acontece que o Vim, apesar de não ter uma boa usabilidade para usuários comuns,
é uma ferramenta muito boa pra programar ainda hoje. Quem não tem medo de
aprender novas linguagens e maneiras diferentes de fazer as coisas fica muito
bem com ele, obrigado. O foco do Vim não é usabilidade, mas eficiência. De
fato, é uma ferramenta ideal para [nerds de
eficiência](http://www.vimgolf.com).

Uma das primeiras coisas a sacar pra usar o Vim de maneira eficiente é que o
modo Normal não tem esse nome à toa: [é o modo planejado pra você usar durante
a maior parte do tempo](http://www.viemu.com/a-why-vi-vim.html). Se você tentar
maximizar o tempo no modo de inserção pra ter uma experiência mais parecida com
a dos outros editores, acabará perdendo as grandes vantagens do Vim -- como a
possibilidade de repetir ações, por exemplo.

Devo ter aprendido isso de alguma forma há um tempo atrás, e já estou até bem
confortável com esse estilo, mas tem algumas coisinhas que ainda me deixam pra
trás no Vim. O que segue são algumas pequenas dicas da minha redescoberta do
Vim dos últimos meses, que teriam feito minha vida um bocado mais fácil se
tivesse sabido delas antes.

1) É mais prático voltar para o modo Normal usando `<Ctrl-C>` em vez de `<Esc>`
-- especialmente se você mapeia a tecla `<caps lock>` para um `<ctrl>`
alternativo, como eu faço. Veja [outras maneiras de evitar o
<kbd>Esc</kbd>](http://vim.wikia.com/wiki/Avoid_the_escape_key).

2) Se a meio caminho de uma seleção visual você se dá conta que começou do
lugar errado, você pode ir para o "outro lado" da seleção usando a tecla `o`
(caractere o minúsculo), modificar o começo da seleção conforme necessário. Use
`o` novamente pra voltar pro outro lado e continuar o que estava fazendo.

3) Acabou de fazer uma operação numa seleção visual e precisa fazer outra na
mesma seleção? Use `gv` pra reselecionar a última seleção, e mande ver.

4) No modo Normal, `<ctrl-o>` leva o cursor pra [última posição antes de um
pulo](http://vim.wikia.com/wiki/Jumping_to_previously_visited_locations).
`<ctrl-i>` faz o caminho inverso. Aprenda isso hoje e me conte depois como você
usou 35 vezes no mesmo dia.

5) Fazer scrolling com `<ctrl-f>`/`<ctrl-b>` (mesmo que
`<pageup>`/`<pagedown>`), `<ctrl-u>`/`<ctrl-d>` (up/down conforme a
configuração scroll) e `<ctrl-y>`/`<ctrl-e>` (sobe/desce uma linha) é mais
prático do que usar `<pageup>`/`<pagedown>`, setinhas e a rodinha do mouse.
Veja [mais sobre movimentação no
Vim](http://vim.wikia.com/wiki/All_the_right_moves).

6) Descobri que manter uma cópia impressa do [*cheatsheet*
gráfico](http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html) por
perto realmente ajuda a aprender mais coisas. Não tanto porque é fácil de
consultar, mas porque você acaba batendo o olho em alguma coisa útil quando
fica entediado. :)


Sobre plugins, existem muitos que valem a pena conferir (tenho pelo menos uns
vinte instalados), mas alguns se tornam essenciais bem rapidinho:

1) [Pathogen](https://github.com/tpope/vim-pathogen) - ajuda a manter os
plugins atualizados e deixa muito fácil para experimentar plugins novos, só por
isso já vale muito a pena. Se ainda não conferiu o Pathogen, [comece por
aqui](http://tammersaleh.com/posts/the-modern-vim-config-with-pathogen).

2) [CtrlP](http://kien.github.io/ctrlp.vim/) - ajuda a achar arquivos dentro do
diretório de um projeto. Se você usa Eclipse, pense `<ctrl-shift-r>`, só que
melhor, porque usa uma busca "fuzzy" por padrão.

3) [Surround](https://github.com/tpope/vim-surround) - mão na roda na hora de
editar texto estruturado a la XML, HTML, etc. Veja um [tutorial do Surround com
vídeo](http://net.tutsplus.com/tutorials/other/vim-essential-plugin-surround/).

Por enquanto é isso! :)
