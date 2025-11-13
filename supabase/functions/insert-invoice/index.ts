import { createClient } from 'npm:@supabase/supabase-js@2.58.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};

interface InvoiceData {
  order_id: string;
  invoice_folio: string;
  xml_content?: string;
  total_amount: number;
  subtotal?: number;
  iva?: number;
  proveedor_nombre?: string;
  rfc_proveedor?: string;
  validados?: number;
  nuevos?: number;
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const invoiceData: InvoiceData = await req.json();

    // Insertar directamente usando el service role key (bypasea el caché de PostgREST)
    const { data, error } = await supabaseClient
      .from('order_invoices')
      .insert({
        order_id: invoiceData.order_id,
        invoice_folio: invoiceData.invoice_folio,
        xml_content: invoiceData.xml_content,
        total_amount: invoiceData.total_amount,
        subtotal: invoiceData.subtotal || 0,
        iva: invoiceData.iva || 0,
        proveedor_nombre: invoiceData.proveedor_nombre,
        rfc_proveedor: invoiceData.rfc_proveedor,
        validados: invoiceData.validados || 0,
        nuevos: invoiceData.nuevos || 0,
      })
      .select()
      .single();

    if (error) {
      console.error('Error inserting invoice:', error);
      return new Response(
        JSON.stringify({ error: error.message }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      );
    }

    return new Response(
      JSON.stringify({ data }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  } catch (error) {
    console.error('Unexpected error:', error);
    return new Response(
      JSON.stringify({ error: (error as Error).message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});