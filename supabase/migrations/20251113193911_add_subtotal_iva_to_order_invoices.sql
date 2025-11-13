/*
  # Agregar campos fiscales a order_invoices

  ## Descripción
  Esta migración agrega campos para almacenar el desglose fiscal de las facturas XML:
  - `subtotal`: Base imponible sin IVA (dato de cfdi:Traslado Base)
  - `iva`: Impuesto al Valor Agregado (dato de cfdi:Traslado Importe)
  
  ## Cambios
  1. Nuevas Columnas en `order_invoices`
    - `subtotal` (numeric): Base sin IVA, default 0
    - `iva` (numeric): Monto del IVA (16%), default 0
  
  ## Notas Importantes
  - Los campos `subtotal` e `iva` permitirán mostrar un desglose fiscal completo
  - La suma de subtotal + iva debe ser igual o cercana al total_amount
  - Estos datos se extraen del elemento cfdi:Traslado del XML de factura
*/

-- Agregar columnas subtotal e iva a la tabla order_invoices
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'order_invoices' AND column_name = 'subtotal'
  ) THEN
    ALTER TABLE order_invoices ADD COLUMN subtotal numeric DEFAULT 0;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'order_invoices' AND column_name = 'iva'
  ) THEN
    ALTER TABLE order_invoices ADD COLUMN iva numeric DEFAULT 0;
  END IF;
END $$;