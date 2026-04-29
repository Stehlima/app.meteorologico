# ClimaBrasil - Integração de Dados Meteorológicos Nacional

Este projeto foi desenvolvido seguindo a sequência de 12 etapas para criar um aplicativo Flutter premium focado no monitoramento climático brasileiro.

## 🔗 Acesse o Aplicativo

Clique no link abaixo para visualizar a demonstração online:
**[Acesse o ClimaBrasil aqui](http://localhost:8081)**

---

## 🛠️ Tecnologias Utilizadas

- **Flutter & Dart**: Base do desenvolvimento cross-platform.
- **HG Brasil Weather API**: Escolhida por ser uma API nacional robusta com dados precisos de cidades brasileiras.
- **Provider**: Gerenciamento de estado eficiente para atualizações em tempo real.
- **fl_chart**: Implementação de gráficos de linha para visualização de tendências de temperatura.
- **Google Fonts (Montserrat)**: Tipografia moderna para um visual premium.
- **Design System**: Paleta baseada em **Azul Oceano** e **Lilás** com componentes semi-transparentes (Glassmorphism).

## 📂 Estrutura do Projeto

- `lib/core`: Temas e constantes globais.
- `lib/data/models`: Modelagem de dados JSON para objetos Dart.
- `lib/data/providers`: Lógica de negócio e estado da aplicação.
- `lib/data/services`: Comunicação com APIs externas e Banco de Dados.
- `lib/ui/pages`: Telas principais da interface.
- `lib/ui/widgets`: Componentes reutilizáveis e gráficos.

## ☁️ Banco de Dados Online
O projeto inclui o `DatabaseService` preparado para integração com **Supabase**, permitindo o armazenamento histórico de consultas e preferências do usuário na nuvem de forma gratuita e escalável.

## 🎨 Design Premium
O aplicativo utiliza gradientes dinâmicos e cartões com efeito de vidro para proporcionar uma experiência de usuário de alto nível, fugindo do padrão básico de aplicativos de clima.
