Title: Aventurando-se com Grails
Date: 2013-06-03 20:09
Author: Elias Dorneles
Status: published

Estou usando [Grails](http://www.grails.org) ativamente há alguns meses
atrás. Comecei fazendo manutenção numa aplicação legada usando uma
versãozinha do Grails já bem gasta. Eventualmente, acabei migrando de
vez, usando Grails 2.x para praticamente todas as aplicações novas lá no
trampo. O bichinho é muito bom!

Quem caiu aqui para ler uma simplificação grosseira, lá vai: Grails é
Rails pra [Groovy](http://groovy.codehaus.org), e
[Groovy](http://groovy.codehaus.org/) é Ruby + Java. [[1]](#f1)

Groovy, pelo menos, inspira-se bastante em ambas as linguagens. De fato,
Groovy é um “Ruby” para os programadores Java que têm preguiça de
aprender outra linguagem. Qualquer programador fluente na linguagem Java
pode [aprender o básico de Groovy em uma horinha de boa
vontade](http://groovy.dzone.com/news/java-groovy-few-easy-steps) e há
[vários](http://streetsaheadllc.com/article/ten-reasons-every-java-developer-should-learn-groovy--part-1-)
[motivos](http://streetsaheadllc.com/article/ten-reasons-every-java-developer-should-learn-groovy--part-2-)
muito bons para fazer isso.

Mas não vou ficar explicando aqui [o que é
Groovy](https://pt.wikipedia.org/wiki/Groovy) e [o que é
Grails](https://pt.wikipedia.org/wiki/Grails), a Wikipedia tá aí pra
isso. Só quero anotar algumas coisas, mesmo -- também não é como se você
estivesse com as expectativas lá muito altas. :P

Como você talvez já se deu conta, as tais [linguagens de domínio
específico
(DSLs)](https://pt.wikipedia.org/wiki/Linguagem_de_dom%C3%ADnio_espec%C3%ADfico)
representam hoje [nossa melhor chance de conseguir reuso em grande
escala](https://eljunior.wordpress.com/2012/12/03/fatos-e-falacias-da-engenharia-de-software-notas-do-livro/)
-- isto é, reuso de soluções para problemas genéricos. Groovy, a
linguagem que empodera Grails, tem vários [recursos justamente pra
facilitar a criação de
DSLs](http://docs.codehaus.org/display/GROOVY/Writing+Domain-Specific+Languages).

E Grails é recheado dessas linguagenzinhas. [[2]](#f2) Tem DSLs para as
configurações em diferentes ambientes, pra customizar o mapeamento de
tabelas no banco de dados, pra configurar recursos estáticos (arquivos
CSS, JS, etc), pra fazer consultas no banco de maneira mais legível, pra
declarar regras de validação, enfim, pra uma pancada de coisa. E tem uma
pancada de [plugins extras](http://grails.org/plugins/) pra você usar
que adicionam ainda outras.

Isso é muito legal porque significa que você consegue fazer muito
escrevendo bem pouco. Compressão. Eu curto. :)

Bem, o caso é que eu tô curtindo muito ter [um REPL dentro da própria
aplicação](http://grails.org/plugin/console), que permite eu vasculhar
os objetos que estão escondidos lá no servidor de aplicação, executar
queries no mesmo banco que a aplicação tá usando, checar a configuração
da aplicação rodando e até mesmo esboçar um novo *feature*.

Além disso, várias coisas que você sofre pra configurar nas aplicações
Java Web comuns (gerenciamento de dependências, build automatizado fora
da IDE, maneira fácil de rodar os testes unitários e de integração,
gerenciamento dos recursos estáticos), com Grails você já ganha tudo
prontinho de graça, bem organizado e em geral, muito mais fácil de
manter.

Nem tudo são flores, todavia. Não curto muito o comportamento default do
[save()](http://www.grails.org/doc/latest/ref/Domain%20Classes/save.html),
essa parada de ele falhar silenciosamente quando a validação não passa.
Estou a par dos [motivos que levaram os desenvolvedores do Grails a
fazer dessa
forma](http://blog.springsource.com/2010/06/23/gorm-gotchas-part-1/),
mas isso é simplesmente contrário ao esperado -- *not the best UX, guys,
and you know it*. Já que não podíamos ter o parzinho *save* e *save!*
como no Rails, bem que o comportamento poderia ter sido invertido aqui
-- *save()* e *saveQuietly(),* talvez?

De qualquer forma, tarde demais. Ainda assim, agora é só a gente lembrar
de colocar `grails.gorm.failOnError=true` lá no `Config.groovy` sempre
que criar uma aplicação nova, e todo mundo fica feliz de novo. :)

<a name="f1"></a>**[1]** É, eu sei, Rails hoje em dia é um animal bem
diferente, mas o fato é que Grails tem muita semelhança com as primeiras
versões do Rails e ainda se inspira muito nele.

<a name="f2"></a>**[2]** Não, as sintaxes das DSLs não são um problema
-- todas elas são meio parecidas, justamente porque usam as mesmas
[construções básicas](http://groovy.codehaus.org/Closures). Você nem
precisa saber que são DSLs. ;-)
