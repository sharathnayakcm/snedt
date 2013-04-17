ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if html_tag =~ /<(label)/
    html_tag
  else
    <<-html
      #{html_tag}
      <div id="#{instance.method_name}_check" class="signupFormError">
        <span class="checkIco errorCheckIco"></span>
        <div class="formError" style="display:block">
          <p>
            #{
              begin
                "#{instance.object_name.classify.constantize.attribute_name_for_display(instance.method_name).capitalize} #{Array(instance.error_message).first}"
              rescue
                "#{instance.method_name.humanize} #{Array(instance.error_message).first}"
              end
            }
          </p>
        </div>
      </div>      
      <script type="text/javascript">
        $j("##{instance.object_name}_#{instance.method_name}").addClass("validate_failure")
        $j(".textInput").each(function() {
          if($j(this).hasClass("validate_failure")==false){
            var id = '#'+$j(this).attr('id')+'_icon';
            $j(this).addClass("validate_success");
            $j(id).addClass("correctCheckIco");
            $j(id).addClass("checkIco");
          }
        })
      </script>
    html
  end
end