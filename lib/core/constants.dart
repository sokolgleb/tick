// Supabase credentials - replace with your own or pass via --dart-define
const supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: 'https://uokxxysjxoqxeyimtanb.supabase.co');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVva3h4eXNqeG9xeGV5aW10YW5iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg5NTY0ODUsImV4cCI6MjEwNDUzMjQ4NX0.1BB590FIGs7-My9RGq8em7AkHLMt906I8FCiiMY97Kk');

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
