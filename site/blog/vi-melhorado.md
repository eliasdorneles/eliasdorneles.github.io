Title: VI Melhorado
Date: 2013-09-26 16:49
Author: Elias Dorneles
Slug: VI-Melhorado

[Practical Vim](http://pragprog.com/book/dnvim/practical-vim) é um livro sobre
o [Vim](http://www.vim.org/) -- o editor de textos xodó dos programadores.
Muito bem escrito, recheado de exemplos e referências, kudos para o [Drew
Neil](http://drewneil.com/), autor dessa belezinha.  Drew também faz vídeos
sobre o Vim, disponíveis gratuitamente em
[http://vimcasts.org](http://vimcasts.org/).

[![Edit Text at the Speed of
Thought](https://eljunior.files.wordpress.com/2013/09/dnvim.jpg?w=250 "Practical
Vim")](http://pragprog.com/book/dnvim/practical-vim)

<!-- PELICAN_END_SUMMARY -->

Se você ainda não conhece o Vim, talvez esse livro não seja um começo
adequado. É bom ter pelo menos seguido o
[vimtutor](http://linuxcommand.org/man_pages/vimtutor1.html). Se você
usa Vim há um bom tempo e está sentindo que não usa todo o potencial da
ferramenta, este livro pode ser o que você precisa.


O livro foi escrito num formato de dicas, demonstrando problemas e
soluções, começando com as mais simples e avançando para outras mais
refinadas, com referências cruzadas entre elas. Isso torna possível você
lê-lo aos poucos, não necessariamente em ordem, portanto fica uma
leitura leve -- como se fosse uma centena de blog posts. Mas eu li na
ordem mesmo assim. :P


Como o livro é extremamente prático e recheado de exemplos, e também como [já
falei algumas coisas a respeito aqui
antes](https://eljunior.wordpress.com/2013/04/07/coisas-sobre-o-vim-que-gostaria-de-ter-sabido-antes/),
vou só falar os destaques que pessoalmente me foram legais.


Um dos pontos centrais do livro é que para usar bem os recursos Vim,
devemos aprender os mecanismos de repetição que ele oferece. Repetir o
último comando, a última mudança no texto, a última macro, a última
busca -- essas funcionalidades ajudam bastante no trabalho de edição,
que é repetitivo por natureza, portanto vale a pena aprender bem como
elas funcionam.


Aprendi a lidar com registradores (*registers*) no Vim, finalmente!  Muitas
vezes antes já senti falta e acabei fazendo a tarefa manualmente ou recorrendo
a uma ou outra mutreta... Você [pode aprender facilmente sobre os registers do
Vim em um tutorial online](http://usevim.com/2012/04/13/registers/), mas o
livro ensina com exemplos práticos, dando a motivação certa pra você aprender
cada comando. Eu já havia lido várias vezes sobre os *registers* online, mas só
depois de ler os pulos do gato no livro que estou me sentindo confortável para
usá-los. São bem úteis na hora de fazer refatorações em código, e montar ações
a serem repetidas com [o comando
ponto](http://stackoverflow.com/questions/7325052/can-someone-explain-to-me-why-the-dot-command-is-so-useful-in-vim).


Uma dica interessante do livro sobre
[macros](http://usevim.com/2012/08/10/macros/) é uma maneira de criar
macros que “param automático”. A ideia é usar um movimento
(*[motion](http://vimdoc.sourceforge.net/htmldoc/motion.html)*) que
falhe quando a macro não deve mais ser aplicada. Quando um movimento
falha na execução de uma macro, o restante da execução é cancelado.
Sabendo disso, podemos tirar proveito na hora de montar e executar a
macro, o que nos permite criar macros "infinitas" que não precisam de
contagem exata e pararão a execução no momento certo.

Descobri algumas coisas legais também sobre a busca do Vim. Se você faz uma
busca usando o comando */* e depois aciona a substituição com a busca vazia
`:s//texto a repor/` o Vim reusa o padrão usado na última busca. Isso é legal
porque permite você refinar a busca visualmente primeiro, e então montar o
comando de substituição depois. Às vezes isso é mais prático do que usar a
busca e substituição pedindo confirmação com `:s/texto a substituir/texto a
repor/gc`. Ah, e quando estiver montando expressões regulares na busca, é uma
boa ideia começar as ERs com o escape `\v` que ativa o [comportamento ”very
magic”](http://www.malloc.co/vim/using-very-magic-to-make-vim-regular-expressions-cleaner/)
-- muito mágico e muito mais fácil.

Outra dica boa sobre busca é [o plugin que muda comportamento do \* e \# no
modo visual](https://github.com/nelstrom/vim-visual-star-search). Por padrão, o
Vim buscará a palavra sob o cursor (coerente com o comportamento no modo
normal), estendendo a seleção. O plugin altera para ele buscar o texto que está
selecionado, o que é bem mais útil. =)



Curti também as explicações sobre a integração do Vim com
[ctags](http://ctags.sourceforge.net/),
[grep](https://en.wikipedia.org/wiki/Grep) & [ack](http://beyondgrep.com/), o
funcionamento do corretor ortográfico, etc -- tem uma seção do livro dedicada a
esses assuntos. Ainda não coloquei muita coisa na prática, mas fiquei cheio de
ideias.



Num mundo em que existem [ferramentas muito inteligentes para edição de
código](http://www.jetbrains.com/idea/) que por vezes até escrevem o código por
você, o Vim tem se mantido relevante porque permite a economia de movimentos em
qualquer tipo de texto. A longo prazo, o Vim ainda é um bom investimento para
quem precisa de uma edição de texto mais refinada, como muitos programadores.
Não todos, porque alguns programadores infelizmente só usarão as linguagens bem
suportadas pela sua IDE. Mas a trupe de teimosos da qual eu faço parte
provavelmente vai se manter usando Vim até o fim -- o benefício vem a longo
prazo.



Enfim, [compre](https://www.amazon.com/Practical-Vim-Thought-Pragmatic-Programmers/dp/1934356980)
[o livro](http://pragprog.com/book/dnvim/practical-vim), [assista os
vídeos](http://vimcasts.org/), siga [o twitter do
Vimcasts](https://twitter.com/vimcasts)...

<sub>Ah, e quando programar em Java, sugiro [usar o Intellij IDEA](http://confluence.jetbrains.com/display/IDEADEV/EAP) -- bem melhor que o Eclipse. :D</sub>
