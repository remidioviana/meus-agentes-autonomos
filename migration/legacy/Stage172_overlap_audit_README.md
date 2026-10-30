# Stage 172 — Auditoria profunda de redundância de 150 agentes

**Data:** 29/10/2026. **Base auditada:** branch `stage171/personal-business-100-individual-native-workflows` + Stage166 registro de 150 + Stage125 registro Societal + Stage171 100 especificações e módulos Kotlin/Swift; análise registrada em `stage172/150-agent-redundancy-diligence`.

## 0. Decisão em uma frase

Há **redundância funcional, de objetivos e de operações potencialmente substancial** entre os 150 candidatos. A redundância técnica entre os 100 novos módulos Personal e Business é **concretamente demonstrada** no código: as 100 especializações Kotlin e as 100 Swift executam o **mesmo motor local `OfflineDraft.preview`**, variando os dados e rótulos da missão. Isso NÃO significa que devam ser fundidas 100 propostas de valor, mas impede afirmar que já operam 100 agentes independentes.

**Nenhuma fusão/eliminação/renomeação foi executada**; 150 IDs e nomes preservados. Sobreposição sem piloto = **hipótese**, não conclusão de que qualquer agente é desnecessário.

## 1. Escopo, método e distinção de evidência

A auditoria cruza **todos os 150 IDs** existentes (50 AE Societal, 50 PE Personal, 50 BU Business), não apenas as 22 colisões preliminares da Stage166.

**Três planos de análise:**

1. **Objetivo** — a necessidade/caso real é a mesma? Mesmo beneficiário, mesmo evento, mesma decisão e métrica final?
2. **Operação** — as ações seriam iguais? Mesmo registro, permissão, ferramenta, origem de dados, revisor e responsabilização?
3. **Função entregue** — o usuário receberia o mesmo artefato? Checklist, evidência, solicitação, encaminhamento, relatório, ticket, avaliação ou confirmação? O código faz operação efetiva ou somente exibe uma interface?

`functional_taxonomy_150.csv` codifica para **cada** agente o domínio da missão, operação, artefato e papel responsável com base no registro fonte. Essa é uma **interpretação explícita do analista**, não uma classificação medida por usuários.

`pairwise_11175_heuristic.csv` cobre os **150×149÷2 = 11.175 pares**, sem pares omitidos. A pontuação é **triagem técnica, NÃO probabilidade de duplicação**:
- mesmo domínio: 28 pontos; mesma operação planejada: 26; mesmo artefato: 21; mesmo papel: 10;
- até 15 pontos de similaridade lexical Jaccard dos textos de ação e palavra inglesa no nome, removendo palavras genéricas;
- **forte** ≥75, **intermediário** ≥56, **fraco** ≥38, **sem sinal por regra** <38.

O componente lexical pode subestimar a similaridade entre ideias em diferentes idiomas e exagerar coincidências de vocabulário; a taxonomia humana, por sua vez, pode errar classes. **Não use pontuação como ranking de qualidade, efeito causal, novidade ou decisão automática de fusão.** O baixo sinal não prova exclusividade.

`curated_overlap_groups.csv`: revisão separada, por missão e controles de acesso, de **45 grupos de sobreposição**. Cada grupo descreve objetivo, operação, artefato, limite entre agentes, proposta de arquitetura e teste capaz de negar a hipótese. Distinguimos `HIGH_RESEARCH_MERGE` (13 grupos), `SHARED_CORE_DIFFERENT_ROLES` (18) e `ADJACENT_NOT_DUPLICATE` (14). Os grupos se sobrepõem: **não os some como número de produtos a excluir.**

`agent_redundancy_exposure_150.csv`: todas as 150 identidades, grupos por agente, top 5 vizinhos e alertas. **123 de 150** aparecem em pelo menos um grupo curado; **27 sem grupo curado NÃO foram declarados únicos**.

## 2. Resultado quantitativo — comparação completa

| Sinal de triagem por par | Quantidade | Interpretação correta |
|---|---:|---|
| Forte (≥75) | **55** | Requer investigação explícita de sobreposição de tarefas |
| Intermediário (≥56) | **36** | Potencial fluxo ou núcleo de função compartilhado |
| Fraco (≥38) | **88** | Coincidência de operação/artefato que pode ser incidental |
| Sem sinal nesta regra | **10.996** | Não significa ausência de redundância |
| **Todos os pares possíveis** | **11.175** | Cobertura combinatória, sem qualquer exclusão |

Cruzamentos dos 55 sinais fortes: **19 AE–PE**, **15 AE–BU**, **9 AE–AE**, **8 PE–PE**, **4 BU–BU**, **0 PE–BU**. O zero PE–BU não significa independência; soluções de duas categorias podem compartilhar motor mesmo que público e dados difiram.

## 3. Achados inequívocos no código real

### 3.1 Personal / Business — redundância de execução demonstrada

- No Stage171, **100 classes/objetos Kotlin separados** e **100 enums Swift separados** carregam informações diferentes (`id`, `name`, `purpose`, `criticalRisk`, `fieldLabels`).
- Em **todos os 100**, o método individual `prepareLocalReview` redireciona para o mesmo `OfflineDraft.preview(descriptor, ...)`. A saída é texto de resumo de entrada **ficcional**, com rótulos "PROVIDED" — a lógica não faz análise de fatura, reconhecimento de acessibilidade, inspeção de alimento, roteamento de chamados ou ação em sistemas externos.
- Uma `MissionCatalog` por plataforma apresenta essa mesma operação a 100 IDs. **100 IDs distintos e 200 arquivos ≠ 100 capacidades autônomas diferentes**.
- Exemplo: `ITHBAT Cancellation` não cancela assinaturas; `TASWIYA Invoices` não reconcilia faturas reais; `IGLAQ Repairs` não comprova reparo encerrado. Os textos descrevem tarefas FUTURAS.

**Conclusão técnica:** reutilização do motor é saudável. O que está incompleto é a diferenciação operacional de cada missão. Nenhum desses 100 foi comprovado como produto standalone, mesmo que seus campos sejam diferentes.

### 3.2 Societal — repetição de interfaces e cálculos simples

No audit trail Stage166 (`source_audit_batch_01..07.csv`), **31/50 pares** de arquivos Android/iOS possuem ambos entradas numéricas simples; **40/50 pares** apresentam avisos de dados fictícios nas duas plataformas. Isso é sinal de implementação preliminar, **não prova que as 31 missões sociais sejam idênticas**.

Demonstração por leitura de fonte:
- `SabilRainActivity.kt` recebe número de preparações e concluídas e devolve `a-b`.
- `AmanaRainActivity.kt` faz igualmente `a-b` para tarefas domésticas.
- `NadaaRepairActivity.kt` subtrai chamados resolvidos de chamados registrados.
- Essas três são funções de subtração de contagens com nomes e rótulos setoriais diferentes. **Há redundância de mecanismo**, não um processo fim a fim de alerta, cuidado ou reparo.

Nem o Stage166 nem esta auditoria representam compilação real em dispositivo, uso de IA, integração autorizada ou prova de impacto humano.

## 4. Grupos prioritários a investigar — objetivos/funcionalidades possivelmente iguais

| Prioridade | Agentes | Falha potencial de estratégia | Abordagem sugerida |
|---|---|---|---|
| P0 | **AE-02 NAZAR / AE-12 QIRAAT / PE-29 MUBIN** | Três experiências de leitura acessível sobre fonte documental | Um motor de leitura com modos RTL, educação e acessibilidade, salvo prova de mercado independente |
| P0 | **AE-03 SANAD / AE-05 CLEAR STEP / PE-10 HUDU / PE-24 YUSR** | Transformam fonte ou procedimento em cartões/etapas legíveis | Uma máquina de passos verificáveis com retomar/desfazer e configuração de acessibilidade |
| P0 | **AE-06 DAIRA / AE-08 HAFIZ / PE-14 TANASUQ** | Rotas, compromissos e responsabilidades de cuidado se sobrepõem | Testar produto de coordenação de cuidado com rotinas e visitas como módulos |
| P0 | **AE-07 ATHAR / AE-48 NIDA** | Dois pareadores de ofertas e pedidos de ajuda comunitária | Testar fluxo único de match com papéis, consentimento e vetos diferentes |
| P0 | **AE-13 MIFTAAH / AE-14 JISR / BU-41 ISTIJABA** | Mesmo atendimento escolar-família fracionado em agenda e fechamento | Uma jornada completa, respeitando controle escolar e acesso dos pais |
| P0 | **AE-27 FADL / BU-26 MIQDAR / BU-28 TAWAQQU** | Três leituras de preparo, porção, buffet e desperdício | Um único modelo de coleta de desperdício com análises modulares |
| P0 | **AE-28 BARAKA / PE-36 AWALAN** | Rotação de alimentos em casa ou despensa institucional | Reusar motor de estoque e testar necessidade de dois produtos comerciais |
| P0 | **AE-29 SATR / PE-22 TABAYYUN / PE-37 TADQIQ** | Leitura e verificação de rótulos, incluindo alergênicos | Leitor comum; alergia exige bloqueios e revisão mais rigorosos |
| P0 | **AE-30 NAWAT / PE-40 FARZ** | Mesma orientação de separação de resíduos | Um catálogo local de regras com compostagem como modo |
| P0 | **AE-32 BARAQ / AE-35 MADA / BU-48 MISDAQIYA** | Escrituração, metas e alegações ambientais compartilham proveniência | Um mecanismo de evidências, cálculo, metas e verificação auditável |
| P0 | **AE-41 DALLA / AE-43 TARTEEB / AE-44 WIFA / PE-08 TASALSUL / PE-17 WATHAIQ / PE-31 JAWAZ / PE-32 ISTIQRAR / PE-49 BIDAYAH** | Vários produtos de perguntas, documentos e dependências oficiais | Motor único de requisitos oficiais com missões especializadas e regras por jurisdição |
| P0 | **BU-06 TASWIYA / BU-08 TATABUQ / BU-10 TANBIH** | Conciliação, divergência e cobranças repetidas na cadeia financeira | Núcleo de tratamento de exceções; regras diferentes para compras e contratos |
| P0 | **BU-11 SALAHIYA / BU-22 TAJDID** | Validade, verificação e aviso de certificados profissionais/de fornecedores | Um motor de vencimentos com permissões e responsabilidade distintas |

Esses são **13 grupos de hipótese forte de consolidação de funcionalidades/produtos**, não 13 fusões executadas. Eles afetam **41 identidades distintas** no registro de exposição, com sobreposição entre grupos. A recomendação não é excluir automaticamente nenhum dos agentes.

## 5. Outros fluxos que devem compartilhar um núcleo sem confundir as responsabilidades

**Manutenção e infraestrutura:** `AE-21 NADAA` + `BU-01 IGLAQ` + `BU-44 SIYANA` podem compartilhar ticket, evidência e aceite, mas cada organização tem autoridade distinta. `AE-23 NUR` + `BU-31 TABRID` (climatização) e `AE-24 HADAR` + `BU-32 ISLAH` (água) são essencialmente **as duas faces do mesmo incidente**, não automaticamente uma só conta/usuário. `PE-01 WUDUH` questiona cobrança; não comprova vazamento.

**Acessibilidade:** `AE-10 JALIS`, `PE-35 TAHAQQOQ`, `BU-34 MUYASSAR` e `AE-25 WADI` podem manter papéis de visitante, morador e gestor, mas devem compartilhar condições de acesso, fonte, data e confirmação. Nenhum pode afirmar que acesso é seguro se desconhecido.

**Mobilidade:** `AE-36 MUTABA`, `AE-38 HATTA`, `AE-39 AYA`, `AE-40 TAMKIN`, `AE-47 HIFZ`, `PE-23 MUAWANA`, `PE-33 BADIL` e `BU-37 MULAAMA` cobrem **etapas da mesma jornada acessível** (preparação, alternativa, confirmação de percurso e despacho). Um ecossistema multimodal com módulos e papéis pode ser mais forte do que oito interfaces isoladas.

**Escola e inclusão:** `AE-15 NABAA` e `BU-42 TATBIQ` compartilham adaptação aprovada, mas professor e coordenador têm deveres diferentes. `AE-13 MIFTAAH`, `AE-14 JISR` e `BU-41 ISTIJABA` precisam demonstrar que agenda, comunicação e fechamento são produtos independentes, não etapas de um fluxo único.

**Food safety:** `AE-26 SUFRA` e `BU-29 TABARRU` compartilham transferência de excedentes, mas apenas profissionais competentes podem validar segurança alimentar; `BU-27 MIYAR` e `BU-30 TAQASSI` têm riscos distintos (temperatura versus recall), mesmo que compartilhem custódia.

**Suporte empresarial:** `BU-16 TARJAMA`, `BU-17 INSAF`, `BU-19 ISTIBAQ` e `BU-20 MARJIYA` cobrem idioma, reclamação, SLA e respostas sustentadas por fontes, normalmente integrados no mesmo helpdesk. Pode haver quatro skills de uma plataforma, não quatro produtos autônomos que mereçam ser avaliados separadamente.

## 6. Armadilhas de pontuação que NÃO justificam fusão

- `AE-31 GHUBAR Day` (poeira) e `AE-46 AMANA Rain` (chuva) compartilham checklist, mas os perigos e protocolos são distintos; **compartilhar UI sem misturar recomendações de segurança**.
- `PE-16 HISAB Remittance` e `PE-38 MUQARANA Prices` compartilham comparação de valores, mas remessa internacional tem regulação, câmbio e riscos diferentes da unidade de supermercado.
- `BU-27 MIYAR Temperature` e `BU-30 TAQASSI Recalls` estão na segurança alimentar, mas devem conservar revisões profissionais diferentes.
- `AE-09 SUKUN` e `AE-20 SAYA` registram bem-estar; o risco de vigilância de trabalhadores torna **perigoso** unificar os contextos de consentimento sem análise.

## 7. Arquitetura alternativa para reduzir redundância sem apagar 150 identidades

Separar **identidade de missão**, **capacidade central** e **produto comercial realmente independente**:

1. **Document Intelligence & Accessible Steps** — leitura, origem, explicação e passos verificáveis.
2. **Human Service Case Ledger** — tickets, responsáveis, passagem, prazos e prova de fechamento.
3. **Personal/Family/Care Scheduling** — rotinas, consentimento, escala e dependências.
4. **Verified Accessibility Knowledge** — local, rota, dispositivo, fonte e validade.
5. **Mobility & Assisted Journey** — rota, confirmação, alternativas e despacho.
6. **Official Document Dependency Engine** — governo, calendário e regras por jurisdição.
7. **Food Inventory / Waste / Transfer** — inventário, preparação, excedente e custódia segura.
8. **Environmental Claims Ledger** — medidas, cálculos, metas, rastreabilidade e auditoria.
9. **Financial Exception Review** — origem de valor, conciliação, discrepância e revisão.
10. **Workforce/Safety Handover** — troca de responsabilidades, incidentes e aceites.
11. **School Accommodation & Family Service** — responsáveis, planos docentes e privacidade infantil.
12. **Human-Comms & Provenance** — mensagens, dúvidas, idiomas, suporte e prova.

Esses **12 possíveis componentes** são proposta de arquitetura, não 12 produtos validados, 12 reduções de custo reais ou equivalência entre riscos legais. Restrições de dados e permissões devem impedir que um núcleo compartilhado misture dados sensíveis entre empresas, famílias, estudantes ou outros contextos.

## 8. Decisão objetiva antes de defender dois agentes como independentes

Para cada grupo de colisão, exigir **um confronto concreto**:

1. **Mesma tarefa real?** Criar exatamente a mesma solicitação/ocorrência para os dois candidatos.
2. **Mesmo usuário e autoridade?** Testar quem pode conferir, acessar, aprovar, transmitir e corrigir.
3. **Mesmo resultado mensurável?** Definir resultado final e denominador, não um número de cliques.
4. **Mesmas ações essenciais?** Um agente pode simplesmente configurar o outro? Demonstrar ferramenta/decisão específica ausente do outro.
5. **Diferenciação sustentada por evidência?** Entrevistas e benchmarks reais, incluindo alternativas incumbentes, concordam com dois jobs-to-be-done independentes?
6. **Resultado contra alternativa combinada:** comparar `produto A`, `produto B`, `plataforma unificada` e `incumbente/manual`. Medir erros, esforço, conclusão, riscos e custo de integração.

Se a solução combinada for equivalente ou superior com menor custo/risco e os compradores forem os mesmos, **propor fusão de funcionalidades e reconsiderar duas candidaturas**. Se compradores, responsabilidades e resultados forem materialmente distintos, conservar **duas missões**, mas compartilhar núcleo quando seguro. Qualquer fusão/renomeação real exige PR de migração com IDs estáveis, aliases e autorização apropriada.

## 9. Execução, rastreabilidade e limitações

Arquivos:
- `functional_taxonomy_150.csv`: 150 tarefas classificadas por quatro dimensões.
- `pairwise_11175_heuristic.csv`: todos os pares, com componentes de cálculo auditáveis e sinal heurístico.
- `curated_overlap_groups.csv`: 45 hipóteses explicadas e critérios para refutá-las.
- `agent_redundancy_exposure_150.csv`: 150 resultados individuais com top 5 vizinhos, cobertura e grau de atenção.
- `check_overlap.py`: valida fontes, origem de nomes, 11.175 pares, scores, grupos, cobertura e a presença do motor compartilhado nos 100 módulos Kotlin/Swift.
- `tests/test_overlap.py`: oito testes de mutação escritos para detectar erro, promoção indevida e fonte perdida.

**Validação realizada nesta execução:** scripts de comparação em JavaScript sobre dados recuperados do repositório, leitura direta dos motores compartilhados, arquivos Societal exemplares, inventário e verificações de contagem. **Ainda não foi executada a suíte Python completa num checkout do repositório**, nem testes de usabilidade, de mercado, de integração real ou builds Android/Xcode. Nenhum resultado causal ou prejuízo por duplicação foi observado.

**Conclusão:** é possível defender o programa Dubai 150 como **150 missões de pesquisa sob um conjunto menor de componentes compartilhados**. Ainda **não é defensável afirmar que há 150 produtos funcionalmente e comercialmente independentes**. Identificamos 13 núcleos prioritários para testar eventual consolidação, e 18 casos de mesmo motor com responsabilidades diferentes. A opção vencedora deve maximizar impacto demonstrado, não quantidade artificial de aplicativos. **Todos os 150 permanecem `RESEARCH_HOLD`, sem fusão, exclusão ou premiação antecipada.**
