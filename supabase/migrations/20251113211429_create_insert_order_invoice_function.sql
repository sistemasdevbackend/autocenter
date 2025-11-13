/*
  # Crear función RPC para insertar facturas

  ## Descripción
  Crea una función RPC para insertar facturas de órdenes con todos los campos,
  incluyendo subtotal e iva. Esto evita problemas con el caché del esquema.

  ## Cambios
  1. Función RPC `insert_order_invoice`
    - Inserta una nueva factura en order_invoices
    - Retorna el ID de la factura insertada
*/

-- Crear función para insertar facturas
CREATE OR REPLACE FUNCTION insert_order_invoice(
  p_order_id UUID,
  p_invoice_folio TEXT,
  p_xml_content TEXT,
  p_total_amount NUMERIC,
  p_subtotal NUMERIC DEFAULT 0,
  p_iva NUMERIC DEFAULT 0,
  p_proveedor_nombre TEXT DEFAULT NULL,
  p_rfc_proveedor TEXT DEFAULT NULL,
  p_validados INTEGER DEFAULT 0,
  p_nuevos INTEGER DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  order_id UUID,
  invoice_folio TEXT,
  total_amount NUMERIC,
  subtotal NUMERIC,
  iva NUMERIC,
  proveedor_nombre TEXT,
  rfc_proveedor TEXT,
  validados INTEGER,
  nuevos INTEGER,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_invoice_id UUID;
BEGIN
  INSERT INTO order_invoices (
    order_id,
    invoice_folio,
    xml_content,
    total_amount,
    subtotal,
    iva,
    proveedor_nombre,
    rfc_proveedor,
    validados,
    nuevos,
    created_at
  )
  VALUES (
    p_order_id,
    p_invoice_folio,
    p_xml_content,
    p_total_amount,
    p_subtotal,
    p_iva,
    p_proveedor_nombre,
    p_rfc_proveedor,
    p_validados,
    p_nuevos,
    NOW()
  )
  RETURNING 
    order_invoices.id,
    order_invoices.order_id,
    order_invoices.invoice_folio,
    order_invoices.total_amount,
    order_invoices.subtotal,
    order_invoices.iva,
    order_invoices.proveedor_nombre,
    order_invoices.rfc_proveedor,
    order_invoices.validados,
    order_invoices.nuevos,
    order_invoices.created_at
  INTO
    v_invoice_id,
    order_id,
    invoice_folio,
    total_amount,
    subtotal,
    iva,
    proveedor_nombre,
    rfc_proveedor,
    validados,
    nuevos,
    created_at;

  RETURN QUERY
  SELECT 
    v_invoice_id,
    order_id,
    invoice_folio,
    total_amount,
    subtotal,
    iva,
    proveedor_nombre,
    rfc_proveedor,
    validados,
    nuevos,
    created_at;
END;
$$;