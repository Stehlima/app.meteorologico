// =====================================================
// CONFIGURAÇÃO SUPABASE - ClimaBrasil
// =====================================================
// 1. Acesse https://supabase.com e crie um projeto
// 2. Vá em Settings > API e copie:
//    - Project URL  -> SUPABASE_URL abaixo
//    - anon/public key -> SUPABASE_ANON_KEY abaixo
// 3. No editor SQL do Supabase, rode o script em:
//    lib/core/constants/supabase_schema.sql
// =====================================================

class SupabaseConfig {
  static const String supabaseUrl = 'https://bbbkvepjpfdtirwvpxqk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJiYmt2ZXBqcGZkdGlyd3ZweHFrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5MzU3OTAsImV4cCI6MjA2MTUxMTc5MH0.nsxaYmHx1isSzqS9nqdsFln0ClAr2qDAhbP2MMRtP2A';

  static bool get isConfigured => true;
}
