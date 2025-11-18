
# DeveloperCat DK

En Flutter applikation med moduler for voice input, data extraction, PDF generation og Supabase integration.

## Projektstruktur

Projektet følger Clean Architecture principper og SOLID design:

- `lib/` - Hovedkildekode
  - `core/` - Kernekomponenter og interfaces
    - `error/` - Fejlhåndtering
    - `util/` - Hjælpefunktioner
    - `security/` - Sikkerhedsrelaterede komponenter
  - `data/` - Data lag (repositories, data sources)
  - `domain/` - Domæne lag (entities, use cases)
  - `presentation/` - UI lag (widgets, screens)
  - `features/` - Funktionalitetsmoduler
    - `voice_input/` - Voice input modul
    - `data_extraction/` - Data extraction modul
    - `pdf_generation/` - PDF generation modul
    - `supabase_integration/` - Supabase integration modul

## Sikkerhedsfunktioner

- Encrypted storage til følsomme data
- Sikker håndtering af API-nøgler
- Brugerautentificering via Supabase

## Kom i gang

1. Installer Flutter SDK
2. Klon dette repository
3. Kør `flutter pub get` for at installere afhængigheder
4. Konfigurer Supabase credentials i `.env` filen (se `.env.example`)
5. Kør `flutter run` for at starte applikationen

## SOLID Principper

Dette projekt følger SOLID principper:
- **S**ingle Responsibility Principle
- **O**pen/Closed Principle
- **L**iskov Substitution Principle
- **I**nterface Segregation Principle
- **D**ependency Inversion Principle