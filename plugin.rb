# frozen_string_literal: true

# name: digest-big-logo
# about: Force bigger logo in digest (summary) emails by rewriting the digest header <img> height (inline attributes/styles).
# version: 1.0.1
# authors: you

after_initialize do
  require_dependency "user_notifications"

  module ::DigestBigLogo
    # ===== EDIT THIS =====
    TARGET_HEIGHT_PX = 90
    # =====================

    def render_digest_header
      html = super
      return html if html.blank?

      h = TARGET_HEIGHT_PX.to_i
      h = 90 if h <= 0

      out = html.dup

      # Replace: height="40" (or any number) on the FIRST <img ...>
      out = out.sub(/(<img\b[^>]*?)\sheight="\d+"/i) do |m|
        m.sub(/\sheight="\d+"/i, %( height="#{h}"))
      end

      # Replace: style="...height:40px..." on the FIRST <img ... style="...">
      out = out.sub(/(<img\b[^>]*\sstyle="[^"]*?)height:\s*\d+px;?/i) do |m|
        m.sub(/height:\s*\d+px;?/i, "height: #{h}px;")
      end

      # Replace: style="...max-height:40px..." if present
      out = out.sub(/(<img\b[^>]*\sstyle="[^"]*?)max-height:\s*\d+px;?/i) do |m|
        m.sub(/max-height:\s*\d+px;?/i, "max-height: #{h}px;")
      end

      # If height wasn't present at all, inject a style on the first <img>
      unless out.match?(/height="#{h}"/i) || out.match?(/height:\s*#{h}px/i)
        out = out.sub(/<img\b/i, %(<img style="height: #{h}px; max-height: #{h}px; width: auto;" ))
      end

      out.respond_to?(:html_safe) ? out.html_safe : out
    end
  end

  ::UserNotificationsHelper.prepend(::DigestBigLogo)
end
