// Supabase credentials - replace with your own or pass via --dart-define
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'YOUR_SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'YOUR_SUPABASE_ANON_KEY');

// Duration presets in minutes
const durationPresets = [5, 10, 15, 30, 60];

// Duration preset labels
const durationLabels = {
  5: '5m',
  10: '10m',
  15: '15m',
  30: '30m',
  60: '1h',
};
