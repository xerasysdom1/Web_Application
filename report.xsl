<?xml version="1.0" encoding="UTF-8"?>
<!-- TigerTech A3 - order report stylesheet. Namespace setup and lookup
     documents are provided. You build TWO views using modes. Fill in the TODOs.
     Dominic Piccini 10/12/2026-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:prod="http://tigertech.example/products"
                xmlns:cat="http://tigertech.example/categories"
                exclude-result-prefixes="prod cat">

   <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

   <!-- the two files you look products/categories up in -->
   <xsl:variable name="products"   select="document('products.xml')"/>
   <xsl:variable name="categories" select="document('categories.xml')"/>

   <xsl:template match="/orders">
      <html>
         <head>
            <title>TigerTech - Order Report</title>
            <style type="text/css">
               body {
               font-family: Arial, sans-serif;
               margin: 24px;
               color: #333;
               }
               h1 { color: #d9531e; }
               h2 { border-bottom: 2px solid #ddd; padding-bottom: 4px; margin-top: 28px; }
               table {
               border-collapse: collapse;
               width: 100%;
               margin-bottom: 24px;
               }
               th, td {
               border: 1px solid #ccc;
               padding: 8px 12px;
               text-align: left;
               }
               th {
               background-color: #f5f5f5;
               }
               .number {
               text-align: right;
               }
               .warning {
               background-color: #ffe6e6;
               color: #c00;
               font-weight: bold;
               }
               .order-header {
               background-color: #fafafa;
               padding: 8px;
               margin-top: 16px;
               font-weight: bold;
               }
               tfoot tr {
               font-weight: bold;
               background-color: #f9f9f9;
               }
            </style>
         </head>
         <body>
            <h1>TigerTech Order Report</h1>

            <h2>Order summary</h2>
            <table>
               <thead>
                  <tr>
                     <th>Order</th>
                     <th>Customer</th>
                     <th>Date</th>
                     <th class="number">Items</th>
                  </tr>
               </thead>
               <tbody>
                  <!-- TODO A: apply templates to each <order> in mode="summary",
                       sorted by @date. -->
                  <xsl:apply-templates select="order" mode="summary">
                     <xsl:sort select="@date"/>
                  </xsl:apply-templates>
               </tbody>
            </table>

            <h2>Order details</h2>
            <!-- TODO B: apply templates to each <order> in the DEFAULT mode,
                 sorted by @date. -->
            <xsl:apply-templates select="order">
               <xsl:sort select="@date"/>
            </xsl:apply-templates>

         </body>
      </html>
   </xsl:template>

   <!-- SUMMARY VIEW (mode="summary") -->
   <xsl:template match="order" mode="summary">
      <!-- TODO C: one <tr> showing @orderID, @customer, @date, and the number of
           items in the order (sum of the line quantities). -->
      <tr>
         <td><xsl:value-of select="@orderID"/></td>
         <td><xsl:value-of select="@customer"/></td>
         <td><xsl:value-of select="@date"/></td>
         <td class="number"><xsl:value-of select="sum(line/@qty)"/></td>
      </tr>
   </xsl:template>

   <!-- DETAILED VIEW (default mode) -->
   <xsl:template match="order">
      <!-- TODO 1: show this order's @orderID, @customer and @date, then a table
           of its <line> items. -->
      <div class="order-header">
         Order <xsl:value-of select="@orderID"/> &#8212;
         <xsl:value-of select="@customer"/> (<xsl:value-of select="@date"/>)
      </div>

      <table>
         <thead>
            <tr>
               <th>SKU</th>
               <th>Product</th>
               <th>Category</th>
               <th class="number">Price</th>
               <th class="number">Qty</th>
               <th class="number">Total</th>
               <th>Status</th>
            </tr>
         </thead>
         <tbody>
            <xsl:for-each select="line">
               <xsl:variable name="lineSku" select="@sku"/>
               <xsl:variable name="lineQty" select="@qty"/>

               <!-- Look up matching product -->
               <xsl:variable name="prod" select="$products//prod:product[@sku = $lineSku]"/>
               <xsl:variable name="catID" select="$prod/@category"/>

               <!-- Look up matching category name -->
               <xsl:variable name="catName" select="$categories//cat:category[@catID = $catID]/cat:name"/>

               <xsl:variable name="price" select="$prod/prod:price"/>
               <xsl:variable name="stock" select="$prod/prod:stock"/>
               <xsl:variable name="lineTotal" select="$price * $lineQty"/>

               <tr>
                  <!-- Apply styling if stock exceeded -->
                  <xsl:if test="$lineQty &gt; $stock">
                     <xsl:attribute name="class">warning</xsl:attribute>
                  </xsl:if>

                  <td><xsl:value-of select="$lineSku"/></td>

                  <!-- TODO 2: prod:name and prod:price -->
                  <td><xsl:value-of select="$prod/prod:name"/></td>

                  <!-- TODO 3: category name -->
                  <td><xsl:value-of select="$catName"/></td>

                  <td class="number">
                     <xsl:value-of select="format-number($price, '$#,##0.00')"/>
                  </td>

                  <td class="number">
                     <xsl:value-of select="$lineQty"/>
                  </td>

                  <!-- TODO 4: line total formatted as currency -->
                  <td class="number">
                     <xsl:value-of select="format-number($lineTotal, '$#,##0.00')"/>
                  </td>

                  <!-- TODO 5: flag if @qty exceeds prod:stock -->
                  <td>
                     <xsl:choose>
                        <xsl:when test="$lineQty &gt; $stock">
                           Out of Stock! (Requested: <xsl:value-of select="$lineQty"/>, Available: <xsl:value-of select="$stock"/>)
                        </xsl:when>
                        <xsl:otherwise>
                           In Stock
                        </xsl:otherwise>
                     </xsl:choose>
                  </td>
               </tr>
            </xsl:for-each>
         </tbody>
         <tfoot>
            <!-- TODO 6: total the items for the order (sum of line quantities) -->
            <tr>
               <td colspan="4" style="text-align: right;">Total Items:</td>
               <td class="number"><xsl:value-of select="sum(line/@qty)"/></td>
               <td colspan="2"></td>
            </tr>
         </tfoot>
      </table>
   </xsl:template>

</xsl:stylesheet>