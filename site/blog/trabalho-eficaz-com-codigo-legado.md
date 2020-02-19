Title: Trabalho Eficaz com Código Legado
Date: 2014-01-26 17:58
Author: Elias Dorneles
Slug: Trabalho-Eficaz-com-Código-Legado

[Trabalho Eficaz com Código
Legado](http://www.grupoa.com.br/livros/engenharia-de-software-e-metodos-ageis/trabalho-eficaz-com-codigo-legado/9788582600320
"Página do livro na editora brasileira") é o título em português do famoso
livro sobre código legado (título original: *[Working Effectively with Legacy
Code](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)*)
escrito por [Michael Feathers](https://twitter.com/mfeathers), um [consultor
muito experiente e reconhecido na comunidade
Agile/XP](http://www.objectmentor.com/omTeam/feathers_m.html). Acabei de ler a
versão traduzida que um amigo emprestou, e a tradução está bem decente -- bem
diferente da [última vez que li um livro técnico em
português](https://eljunior.wordpress.com/2013/01/15/aventuras-com-java-ee/
"Aventuras apresentando Java EE a mim mesmo").

[![Capa do
livro](https://eljunior.files.wordpress.com/2014/01/trabalho_eficaz_codigo_legado.jpg?w=210)](http://www.grupoa.com.br/livros/engenharia-de-software-e-metodos-ageis/trabalho-eficaz-com-codigo-legado/9788582600320)

Veja alguns links sobre o livro, e meu resumo/resenha a seguir:

- [Página sobre o livro na
  WikiWikiWeb](http://c2.com/cgi/wiki?WorkingEffectivelyWithLegacyCode)
- [Working Effectively with Legacy Code na
  Amazon](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
- [Página da versão traduzida no grupo de editoras Grupo
  A](http://www.grupoa.com.br/livros/engenharia-de-software-e-metodos-ageis/trabalho-eficaz-com-codigo-legado/9788582600320)
- [Tópico no programmers.SE com resumo dos pontos chave do
  livro](http://programmers.stackexchange.com/questions/122014/what-are-the-key-points-of-working-effectively-with-legacy-code)
- [Paper do Michael Feathers que originou o
  livro](http://www.objectmentor.com/resources/articles/WorkingEffectivelyWithLegacyCode.pdf)

A definição do livro para código legado é basicamente, código sem
testes. Eis a resposta do livro à pergunta: “o que os testes têm a ver
com o código ser ruim?”:

> Código sem testes é código ruim. Não importa o quão bem escrito, nem
> se ele é bonito, orientado a objetos ou se foi bem encapsulado. Com
> testes, podemos alterar o comportamento de nosso código de maneira
> rápida e verificável. Sem eles, não temos como saber se nosso código
> está melhorando ou piorando.

Quando você precisa alterar código que você mesmo fez, é um pouco mais
difícil de fazer isso de forma segura se o código não tem uma suíte de
testes (especialmente se faz mais de meses que você mexeu nele pela
última vez). Agora, se o código que você precisa alterar foi escrito por
outra pessoa, é um pouco mais difícil de alterar com segurança se ele
não tiver testes. Se esse código que você precisa alterar foi feito por
uma equipe de pessoas diferentes, misturando estilos diferentes, e não
tem uma suíte de testes, sua tarefa é um bom bocado mais difícil. E se
foi escrito por várias pessoas diferentes, em períodos de tempo
diferentes, passando por uma série de restrições de prazos e falhas de
comunicação: com testes já seria complicado, sem testes automatizados
certamente será uma tarefa muito lenta, laboriosa e propensa a erros.

Por isso, essa definição para código legado faz bastante sentido. Se
você está escrevendo código sem testes, você está escrevendo código
legado. Daí a importância desse livro: código legado não é apenas código
daquele projeto que você cai de pára-quedas e tem que tentar entender o
que os programadores que trabalharam nele fizeram. O seu próprio código
vira código legado em questão de minutos, caso você não esteja
escrevendo uma suíte de testes para ele.


Quando você tenta submeter a testes esse tipo de código que não foi
escrito para ser testável, você frequentemente descobre que não consegue
testá-lo sem refatorar algumas partes. Mas pra fazer refatorações com
segurança, você quer ter testes que verifiquem se as refatorações não
estão quebrando nada. E aí você fica sem nenhuma escolha boa:


1) ou você arrisca refatorar um pouco para adicionar testes depois e então
alterar com mais segurança

2) ou arrisca tudo de vez e sai alterando sem testes mesmo


Acho que todos nós fazemos isso de vez em quando -- pelo menos, eu sei
que sou culpado de escrever muito código legado. Manter uma cobertura de
testes alta é difícil quando você não tem treino ou confiança nesse
método de trabalhar. Além disso, infelizmente é muito fácil racionalizar
que você está melhor do que a maioria, porque tem *“muito código pior em
produção por aí”* -- o que não é uma atitude muito saudável.


Enfim, a utilidade dos testes de unidade é o tipo de coisa que talvez
você tenha que verificar por si próprio. Mas o livro do Michael Feathers
não é sobre testes. O propósito do livro é ensinar passo-a-passo a fazer
as pequenas cirurgias-refatorações necessárias para transformar um
trecho de código em algo testável, para a seguir você conseguir
submetê-lo a testes e fazer as alterações necessárias com mais
segurança.


Muitas vezes essas pequenas cirurgias elaboradas para serem minimamente
invasivas podem deixar o código um tanto feio, com uma estrutura
estranha. Mas não faz mal. A ideia nesse momento é deixá-lo testável,
permitindo-lhe alterá-lo com segurança. Depois de fazer as alterações
necessárias guiadas por testes, você poderá refatorar para uma estrutura
mais adequada, desta vez com a ajuda dos testes que você escreveu.


Para isso, o autor explica quais são as coisas necessárias para deixar
um código testável, e passa vários truques para transformar código
*spaghetti* em código testável, um degrau de cada vez. Alguns truques de
quebra de dependências você provavelmente já usou de uma forma ou outra,
embora talvez não com foco em melhorar a testabilidade. Muitos deles são
simples, mas nunca teriam me ocorrido antes do livro.


Um conceito central do livro é o modelo de **pontos de extensão**
(tradução de *[Software Seam](http://c2.com/cgi/wiki?SoftwareSeam)* --
 literalmente, *costura de software*). Pontos de extensão são os locais
do código que permitem embutir um comportamento diferente sem ser
necessário editar o código diretamente no local. Pontos de extensão
colocados nos lugares apropriados permitem que você **isole** o código
sendo testado do restante e também **detecte** as diferenças no
comportamento do código sendo exercitado pelos testes -- duas ideias
importantes para testabilidade que o livro também explica em mais
detalhes.


Um exemplo de ponto de extensão é a chamada de um [método
virtual](https://pt.wikipedia.org/wiki/M%C3%A9todo_virtual) (isto é, um
método que pode ser sobrescrito) em uma linguagem orientada a objetos.
Se você tem um método *updateDb()* chamando um método virtual
*getConnection()* na mesma classe, você poderá criar uma nova classe que
estenda a anterior sobrescrevendo o método *getConnection()* para
retornar um objeto de conexão diferente. Nesse caso, a chamada ao método
virtual *getConnection()* corresponde ao que Feathers chama de um *ponto
de extensão de objeto*, por ser característico das linguagens orientadas
a objetos.


O livro é muito bem escrito, mas talvez lê-lo do começo ao fim como fiz
pode não ser o método mais eficiente de aproveitá-lo. Boa parte do livro
(a parte 2 das 3 que compõem o livro) foi escrita num formato de *FAQ -
Perguntas Frequentes*, cujos capítulos podem ser lidos mais ou menos em
qualquer ordem, são cheios de referências cruzadas e tornam o livro
perfeito para manter ao alcance e usar como referência na hora de
resolver um problema. A terceira parte do livro é um catálogo das
refatorações que foram referenciadas nos capítulos da parte 2, contendo
uma descrição e os passos para aplicar cada refatoração. Isso deixa o
conteúdo um pouco repetitivo se você lê todos os capítulos em sequência,
como eu fiz.


Mas a primeira parte, que tem um material mais introdutório, disseca a
mecânica de fazer alterações e consegue efetivamente vender a ideia da
importância de testes de unidade na manutenção de software. Além de
apresentar a motivação, Michael Feathers explica também as
características encontradas em bons testes de unidade:

1.  São executados rapidamente
2.  Ajudam a localizar problemas de imediato

Ele é incisivo: **um teste de unidade que leve 1/10 de segundo para ser
executado é um teste lento**.


Você quer rodar milhares desses testes ao mesmo tempo, por isso é desejável que
sua execução não seja lenta. Se você tem 3 mil classes com 10 testes de unidade
cada um levando 1/10 de segundo, levará cerca de 1 hora para rodar todos os
testes -- isso é muito tempo para ter feedback sobre uma alteração. Mesmo que
você não tenha 3 mil classes, os números não melhoram muito. Dez minutos é
tempo demais para esperar por feedback. Quando os testes estão demorando 10
minutos para executar, vale a pena rodar apenas um subconjunto deles quando
fazendo alterações; e rodar a suíte inteira talvez em intervalos de horas ou
antes de fazer *commit* no sistema de controle de versão. Mas é bom se esforçar
para obter uma suíte de testes que executem rapidamente.


Alguns testes se parecem com testes de unidade. Testes que acessam o
banco de dados, que usam a rede, que usam o sistema de arquivos, podem
se parecer com testes de unidade, mas não o são. Não quer dizer que não
são úteis: certamente são úteis! Mas é interessante separá-los dos
verdadeiros testes de unidade, que focam em um trecho específico do seu
código de produção e que você pode executar rapidamente quando estiver
fazendo alterações.


Bem, o livro é altamente recomendado, e não só por mim. Está destinado a
ser um clássico na biblioteca dos programadores profissionais por muito
tempo, sem dúvida. Leia o livro e mergulhe de cabeça.


