import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

/// Genera estilos CSS personalizados para contenido HTML
/// adaptados al tema actual (light/dark)
///
/// Esta función centraliza los estilos para contenido renderizado
/// desde WordPress y otras fuentes HTML, asegurando consistencia
/// y soporte completo de temas oscuros/claros.
///
/// Soporta:
/// - Imágenes de WordPress (.wp-block-image)
/// - Citas en bloque (blockquote, .wp-block-quote)
/// - Bloques de código (<pre>, .wp-block-code)
/// - Encabezados (h1-h4)
/// - Tablas
/// - Links
/// - Código inline
Map<String, String>? buildHtmlStyles(
  BuildContext context,
  dom.Element element,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final primaryColor = theme.colorScheme.primary.toARGB32()
      .toRadixString(16)
      .substring(2)
      .padLeft(6, '0');

  // WordPress Images
  if (element.classes.contains('wp-block-image')) {
    return {
      'border-radius': '12px',
      'margin': '16px 0',
      'box-shadow': isDark
          ? '0 4px 6px rgba(0,0,0,0.3)'
          : '0 2px 4px rgba(0,0,0,0.1)',
    };
  }

  // WordPress Quotes & Blockquotes
  if (element.classes.contains('wp-block-quote') ||
      element.localName == 'blockquote') {
    return {
      'border-left': '4px solid #$primaryColor',
      'padding-left': '16px',
      'margin': '24px 0',
      'font-style': 'italic',
      'background-color': isDark ? '#2a2a2a' : '#f9f9f9',
      'border-radius': '4px',
      'padding': '16px',
    };
  }

  // Code blocks
  if (element.classes.contains('wp-block-code') ||
      element.localName == 'pre') {
    return {
      'background-color': isDark ? '#1e1e1e' : '#f5f5f5',
      'padding': '12px',
      'border-radius': '8px',
      'overflow-x': 'auto',
      'font-family': 'monospace',
      'color': isDark ? '#e8e8e8' : '#212121',
      'border': '1px solid ${isDark ? "#333" : "#ddd"}',
    };
  }

  // Inline code
  if (element.localName == 'code') {
    return {
      'background-color': isDark ? '#2c2c2c' : '#f0f0f0',
      'padding': '2px 6px',
      'border-radius': '4px',
      'font-family': 'monospace',
      'color': isDark ? '#e8e8e8' : '#212121',
    };
  }

  // H1 & H2
  if (element.localName == 'h1' || element.localName == 'h2') {
    return {
      'color': '#$primaryColor',
      'margin-top': '24px',
      'margin-bottom': '12px',
      'font-weight': 'bold',
    };
  }

  // H3 & H4
  if (element.localName == 'h3' || element.localName == 'h4') {
    return {
      'margin-top': '20px',
      'margin-bottom': '10px',
      'font-weight': 'bold',
    };
  }

  // Tables
  if (element.localName == 'table') {
    return {
      'border': '1px solid ${isDark ? "#444" : "#ddd"}',
      'border-radius': '8px',
      'overflow': 'hidden',
      'width': '100%',
      'margin': '16px 0',
    };
  }

  // Table cells
  if (element.localName == 'th' || element.localName == 'td') {
    return {
      'border': '1px solid ${isDark ? "#444" : "#ddd"}',
      'padding': '8px',
      'text-align': 'left',
    };
  }

  // Table headers
  if (element.localName == 'th') {
    return {
      'border': '1px solid ${isDark ? "#444" : "#ddd"}',
      'padding': '8px',
      'background-color': isDark ? '#2c2c2c' : '#f5f5f5',
      'font-weight': 'bold',
    };
  }

  // Horizontal rule
  if (element.localName == 'hr') {
    return {
      'border': 'none',
      'height': '1px',
      'background-color': isDark ? '#333333' : '#ddd',
      'margin': '24px 0',
    };
  }

  // Links
  if (element.localName == 'a') {
    return {
      'color': '#$primaryColor',
      'text-decoration': 'underline',
    };
  }

  // Unordered & ordered lists
  if (element.localName == 'ul' || element.localName == 'ol') {
    return {
      'margin': '12px 0',
      'padding-left': '24px',
    };
  }

  // List items
  if (element.localName == 'li') {
    return {
      'margin': '6px 0',
    };
  }

  // Paragraph
  if (element.localName == 'p') {
    return {
      'margin': '12px 0',
      'line-height': '1.6',
    };
  }

  return null;
}
