Title: Goodbye, JSF!
Date: 2013-06-23 13:31
Author: Elias Dorneles

Ok, se você não é javeiro, talvez nunca tenha ouvido falar em JSF. *No
worries*, você não está perdendo muita coisa.

Porém, se você aprendeu a programar em Java, talvez nem tenha procurado
aprender outra linguagem de propósito geral (... *ainda*, I hope) mas já
se interessou por programar para a Web, nesse caso provavelmente já
ouviu falar, talvez deu uma conferida, ou quem sabe está ferrado tendo
que manter aplicações escritas com o [Java Server Faces -- aka
JSF](https://pt.wikipedia.org/wiki/JavaServer_Faces).

Os motivos para o meu ranço com JSF são vários. Alguns problemas que eu
vejo são técnicos, outros são culturais e outros são meio filosóficos,
mesmo.

Há uns anos atrás, quando tive meu primeiro contato com JSF, odiei a
tecnologia com todas as minhas forças. Meu background com Web era
principalmente
[LAMP](https://en.wikipedia.org/wiki/LAMP_(software_bundle)) -- muito PHP
e um pouquinho de Python/Django -- e todo aquele mundo JSF de
componentes no servidor era uma coisa **muito** distante. Continua sendo
distante de certa forma, mas hoje a coisa até que está melhorzinha para
o JSF.

Enfim, pude ter uma compreensão melhor da coisa quando, depois de passar
2 anos reclamando, resolvi brigar de volta. Decidi lutar com o dragão,
ia aprender como a bagaça funcionava, pra depois poder xingar com
propriedade -- em um post comprido no blog! :P

Comecei a acompanhar a [tag JSF no
StackOverflow](http://stackoverflow.com/tags/jsf/ "JSF taginfo"), li e
reli as respostas e perguntas dos top usuários e comecei a tentar
responder as perguntas de outros -- a velha tática de aprender tentando
resolvendo problemas mais ou menos reais.

Nesse caminho, acabei aprendendo bastantes coisas, e à medida que fui
dominando mais a parada eu estava até já quase começando a gostar -- mas
aí aconteceu que  [Grails](http://grails.org) meio que [se meteu no meio
da
história](https://eljunior.wordpress.com/2013/06/03/aventurando-se-com-grails/)
e o meu ranço com JSF voltou. Aliás, estou atualmente lendo o livro
[Programming
Grails](http://shop.oreilly.com/product/0636920024750.do "Programming Grails - pagina do livro") e
estou descobrindo tudo tão mais fácil que Java/JSF, que decidi
compartilhar logo meu *rant* antes que eu apague da memória. :P

Problema técnico chato de JSF
=============================

O grosso da lógica de UI fica no lado servidor. *Yeah*, os browsers
estão cada vez mais espertos, a tendência tem sido
*fat-client/thin-server* já há algum tempo, e JSF ainda tá nessa de usar
o servidor pra controlar quase tudo da interface. Isto significa que
mesmo para pequenas atualizações na tela do lado cliente, você
**precisa** fazer novas requisições AJAX ao servidor.

Pior, para suportar isso, o objeto que representa a árvore de
componentes (view state) de cada página XHTML é armazenada no servidor.
Para cada acesso... Para cada usuário... Por várias requisições
consecutivas... [1]

Está vindo aí no [JSF 2.2](http://jdevelopment.nl/jsf-22/ "JSF 2.2") o
suporte a [Stateless
Views](https://jsfcorner.blogspot.com.br/2013/05/jsf-22-stateless-views-explained.html) (basicamente,
páginas que não precisem de armazenar a árvore no servidor) para amainar
o problema, mas como para usá-las você precisa abrir mão de várias
comodidades do framework
([@ViewScoped](http://docs.oracle.com/javaee/6/api/javax/faces/bean/ViewScoped.html),
por exemplo), não percebo tanto avanço assim. [2]

Problema filosófico chato de JSF
================================

[Design by comittee](https://en.wikipedia.org/wiki/Design_by_committee)
-- no caso, não só de JSF, mas de [Java
EE](https://en.wikipedia.org/wiki/Java_Platform,_Enterprise_Edition) em
geral. As coisas demoram muito pra evoluir esperando pelos comitês de
*experts* resolverem as coisas, e não ficam com a melhor qualidade por
causa disso. Spring está aí sustentando a controvérsia há já alguns anos
-- existe uma velha discussão Spring (projeto graúdo open source
tradicional, evolui sem especificação) vs Java EE (uma cacetada de
especificações, todo um processo para sugestão de melhorias,
implementações de referência de cada especificação espalhadas em
projetos open source mundo afora e reunidas no
[Glassfish](https://glassfish.java.net)) que já está meio gasta mas
[ainda
sobrevive](http://stackoverflow.com/questions/2822812/spring-3-0-vs-java-ee-6-0).

Uma das coisas chatas desse problema é que seguidamente algum ingênuo
que pensa de forma conservadora vai dizer pra você que é melhor usar
Java EE porque é “*standardized*”, querendo dizer que é padronizado,
especificado e tudo o mais. Escolhendo Java EE você supostamente não se
prenderia a nenhum fabricante (já que tem várias implementações das
espeficações), e evita o “lock-in” que você está sujeito se usar Spring.
*OH NO, vamos ficar presos à uma solução “proprietária”*! Nevermind que
o Spring é open source, e que existem muitos empreendimentos por aí
usando .NET e outras coisas *realmente* proprietárias, do tipo em que o
*lock-in* é real, e tudo continua funcionando mesmo assim. Dá pra
imaginar?

Fora que você não ganha muita liberdade de escolha indo com Java EE. O
que acaba acontecendo é que você acaba escolhendo um servidor de
aplicação, pelo menos uma biblioteca de componentes e fica preso neles
até o fim. Experimenta mudar pra ver se você não está em *vendor
lock-in*... E agora?

Enfim, na minha opinião, esses argumentos são balela. As reais vantagens
e desvantagens que diferenciam um e outro estão relacionadas a políticas
de configuração. Com Spring, o *deploy* é usualmente obter um WAR que já
tem todas as configurações que a aplicação precisa dentro, e basta
jogá-lo no servidor de aplicação -- a configuração de ambiente é
usualmente feita em tempo de *build*. Com Java EE, você precisa fazer
todas as configurações necessárias para a aplicação (datasources, filas,
etc) no servidor de aplicação (ainda bem que a interface pra configurar
é padrão em todos os servidores de aplicação... *NOT!*), e geralmente
tem alguém responsável pela configuração que acaba mexendo nos WARs,
EARs e JARs da vida. Como algumas empresas têm equipes dedicadas para
cuidar da infra Java (e têm medo de deixar os desenvolvedores mexer no
banco de produção), o Java EE é jogo pra elas.

Problema cultural chato de JSF
==============================

Acabo classificando esse problema como cultural porque é uma coisa que
fica meio "aceita" pelo pessoal, e se reflete na maioria das aplicações.
Basicamente, a curva de aprendizado é escarpada e longa **demais**!
Fazer JSF de um jeito decente exige aprender o famoso [ciclo de
vida](http://docs.oracle.com/javaee/6/tutorial/doc/bnaqq.html) (um
[objeto](https://javaserverfaces.java.net/nonav/docs/2.0/javadocs/javax/faces/lifecycle/Lifecycle.html)
usado pra controlar toda a putaria que exige programação Web baseada em
componentes com Java), sacar que o código dentro do seu XHTML passa por
várias fases de execução diferentes (construção da view, renderização da
view, HTML renderizado rodando no browser) e uma cacetada enorme de
pegadinhas não-intuitivas. Aprender todas essas coisas leva um tempo
danado!

O resultado é que você só aprende a coisa pela metade, decidindo que não
vale a pena ir muito a fundo, acaba se conformando com as soluções
existentes e fica esperando que alguém mais encarnado resolva os
problemas parecidos com os que você está tentando resolver -- pra depois
você copiar a solução. A galera que programa em JSF acaba conhecendo o
[BalusC](https://balusc.blogspot.com "BalusC's blog") de uma maneira ou
outra, basicamente porque ele resolve a maioria dos problemas práticos
de JSF antes de todo mundo. Esse cara é um herói de Java EE -- ele manja
mais de JSF que os próprios desenvolvedores da parada!

Ele faz algumas coisas importantíssimas que mantêm JSF vivo: mantém o
[OmniFaces](http://code.google.com/p/omnifaces) (um projeto de código
aberto simplesmente imperdível pra quem programa JSF 2.x), escreve
tutoriais [bem completos e compreensíveis no seu
blog](https://balusc.blogspot.com), e responde ativamente as [perguntas
no Stackoverflow](http://stackoverflow.com/tags/jsf* "tag JSF no SO").
Aprendi muito desse cara -- além de ser um
[maven](https://en.wikipedia.org/wiki/Maven) de Java/JSF, é um cara muito
generoso compartilhando seu conhecimento e sempre atencioso. *Hey,
Bauke, all the JSF devs in the world thank their gods for your very
existence and spetacular work. You rock, dude!*

Bem, mas como ele é ele, e eu sou eu, ele provavelmente está nesse
momento estudando, produzindo, escrevendo ou [ajudando a galera no
SO](http://stackoverflow.com/tags/jsf/), enquanto eu tô aqui, escrevendo
só mais um *rant* no blog.

Enfim, para esse post não ficar só na reclamação, vou usar o velho
truque de jornalista e colocar aqui...

10 coisas que todo desenvolvedor JSF precisa saber
==================================================

Ok, está mais para 10 perguntas e respostas do StackOverflow que todo
desenvolvedor JSF precisa ler, mas tá valendo! :)

1. [Como funcionam os tais servlets? O que acontece quando eu inicio uma aplicação, e em que ordem?](http://stackoverflow.com/questions/3106452/how-do-servlets-work-instantiation-session-variables-and-multithreading)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Entender como funcionam os servlets, filtros, listeners, as sessões e
como funciona tudo isso em cima do protocolo HTTP ajuda bastante na hora
de resolver problemas -- são os fundamentos de Java Web. A explicação
concisa e bem completa contida nessa resposta do BalusC simplesmente não
tem preço.

2. [Porque os métodos getters são chamados várias vezes durante a mesma requisição?](http://stackoverflow.com/questions/2090033/why-jsf-calls-getters-multiple-times)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------

Boa pergunta! Leia essa pra saber por que você não deve fazer chamadas
de acesso ao banco dentro de um método *getAlgumaCoisa()* nos seus
backing beans. E sim, eu também já fiz isso antes e tive que mudar
tudo... Contra-intuitivo, ou não?

3. [Meu botão ou link não está sendo acionado! Ai mel dels, e agora?](http://stackoverflow.com/questions/2118656/hcommandlink-hcommandbutton-is-not-being-invoked)
------------------------------------------------------------------------------------------------------------------------------------------------------------------

Rá! Você caiu na armadilha! Leia todos os itens possíveis nessa
resposta, é uma excelente checklist na hora de depurar problemas. Você
vai acabar aprendendo um bocadinho de JSF, vai se dar conta que o BalusC
é um herói por conseguir fazer as coisas acontecerem mesmo JSF sendo a
droga que é -- e escrever respostas completíssimas no SO.

Quero dizer, olhe para aquela lista! Ninguém devia ter TANTO possíveis
problemas afetando se um botão vai realmente fazer o esperado! Talk
about bad developer UX...

4. [Quando devo usar links e quando usar commandLinks?](http://stackoverflow.com/questions/4317684/when-should-i-use-houtputlink-instead-of-hcommandlink)
---------------------------------------------------------------------------------------------------------------------------------------------------------

HTTP: GET vs POST.  Navegação/favoritabilidade vs. ações do tipo altera/cria
alguma coisa. A maioria dos desenvolvedores JSF levaram 10 anos para aprender
[quando usar GET vs POST](http://www.w3.org/2001/tag/doc/whenToUseGet.html).
Alguns ainda não aprenderam...  

5. [Como passar parâmetro para um commandLink dentro de um datatable?](http://stackoverflow.com/questions/4994458/how-can-i-pass-a-parameter-to-a-commandlink-inside-a-datatable)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Datatables são basicamente inúteis se você não puder fazer uma ação para
agir no registro de uma linha. Isso às vezes é mais difícil do que
parece. Leia essa para não sofrer na próxima vez que precisar fazer
isso. E não seja bobo: se estiver usando um container antigo, [use a
JBoss-EL logo e largue de
frescura](http://stackoverflow.com/questions/3284236/invoke-direct-methods-or-methods-with-arguments-variables-parameters-in-jsf)!

6. [Meu jQuery não tá funcionando! \#comofas](http://stackoverflow.com/questions/10726653/by-default-jsf-generates-unusable-ids-which-are-incompatible-with-css-part-of)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

JSF gera ids no HTML usando o dois-pontos **':'** como separador, isso
acaba gerando alguma confusão porque o dois-pontos é um separador com
significado diferente para a nossa *[beloved Javascript library
jQuery](http://www.jquery.com "jQuery rocks!")*. Aprenda como evitar ser
mordido por esse problema.

Talvez você possa aproveitar o ensejo pra mudar de hábito: como atrelar
comportamento pelo *id* do elemento HTML não escala, há quem digo que é
melhor usar sempre *classes*. Dizem que é como o Gmail faz, mas nunca
conferi... (sim, eu tenho medo do JavaScript compilado do Gmail).

7. [Como usar Composite Components?](http://stackoverflow.com/tags/composite-component/info)
--------------------------------------------------------------------------------------------

Ok, dessa vez o link não é para uma pergunta/resposta no SO, mas para a
wiki da tag composite-component. Aí tem um tutorial bacana ensinando a
criar um [Composite
Component](http://docs.oracle.com/javaee/6/tutorial/doc/giqzr.html). Se
você está usando JSF 2.x e ainda não fez algo do tipo, tire uma meia
horinha pra seguir o tutorial lá, vale muito a pena -- é a maneira mais
efetiva de reuso para as páginas JSF.

8. [Facelets templates, Facelets tags, Composite Components, Custom Components, aaargh! WTF are they about, anyway?](http://stackoverflow.com/questions/6822000/when-to-use-uiinclude-tag-files-composite-components-and-or-custom-componen)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Pois é, era de esperar que reuso em um framework baseado em componentes
fosse algo trivial, claro, tranquilo e sussa. *Hmmmm, not really*! Você
ainda precisa ficar ligado em muita coisa pra fazer as coisas
funcionarem do jeito que você quer.

Acho que a dica maior aqui é que os ids dos objetos dentro dos
componentes são únicos para a própria instância, isto é, cada vez que
você usar o componente numa página, os outros componentes dentro dele
terão identificador prefixado pelo id do componente que você criou. Isso
facilita na hora de fazer componentes AJAX reusáveis, porque o alvo das
alterações (o que você usa no render) sempre terá uma identificação
única para aquele componente.

9. [Comunicação em JSF 2.0 -- como passar os dados que eu quero para onde eu preciso](https://balusc.blogspot.com.br/2011/09/communication-in-jsf-20.html)
---------------------------------------------------------------------------------------------------------------------------------------------------------

Bom... se você está usando JSF 2.x, provavelmente já chegou esse artigo
antes. Eu nem precisaria postar, porque é tão batata que todo mundo
usando JSF 2.x deve cair nele toda hora, mas como tenho a impressão que
meu eleitorado não gosta de textos grandes, é bom colocar na lista. Você
não vai ler agora mesmo, então sugiro favoritar a página e ir lendo aos
poucos durante a semana.

10. [Por fim, uma breve história de JSF](http://stackoverflow.com/questions/3623911/what-are-the-main-disadvantages-of-java-server-faces-2-0)
---------------------------------------------------------------------------------------------------------------------------------------------

Apesar de reclamar um bocado sobre JSF, reconheço que ele está
melhorando, e nos últimos anos tem andado melhor do que antes. É bom
estar a par de como a coisa começou, os problemas foram aparecendo, como
eles foram sendo (lentamente) resolvidos, como outros apareceram no
processo, e como alguns ainda estão esperando solução. Toda tecnologia
acaba tendo um certo ciclo de vida, e é sempre bom saber o caminho que
está seguindo as ferramentas que você está investindo.

Eu, por exemplo, comecei a me afastar de JSF depois que [o Ed Burns
(lead developer de JSF) confirmou que JSF vai continuar sempre mantendo
a maior parte da lógica de UI no lado
servidor](http://www.infoq.com/news/2012/01/jsf-update-2.x). Realmente
faz sentido pra JSF se manter assim, afinal, sempre vai existir
desenvolvedores que não estão muito a fim de aprender coisas novas,
empresas que vão postergar upgrades por anos, enfim... Ainda vai ter
muita aplicação JSF pra ser mantida nos próximos 20 anos. Mas eu prefiro
investir numa tecnologia que me ajude a alavancar as demais tecnologias
da Web (especialmente as que eu preciso conhecer de qualquer forma, como
HTML/CSS/HTTP), e não uma em que as [abstrações simplesmente vazam
demais](https://en.wikipedia.org/wiki/Leaky_abstraction "abstrações vazadas na Wikipedia em inglês") e
dificultam usar os outros blocos da construção. Para mim, JSF está
definitivamente no último grupo. So... *Goodbye, JSF!*

[1] No Mojarra, a implementação de referência de JSF, o default é
armazenar a *view* por 15 requisições consecutivas; outras
implementações/configurações podem variar.

[2] A idéia de stateless views em JSF foi implementada pela primeira vez
por um consultor australiano, que pelo jeito [compartilha a mesma idéia
de que UI no servidor é
roubada](http://www.industrieit.com/blog/2011/11/stateless-jsf-high-performance-zero-per-request-memory-overhead/).
