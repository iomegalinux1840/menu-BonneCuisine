class SubdomainConstraint
  def self.matches?(request)
    # Match if there's a subdomain that's not reserved
    return false if request.subdomain.blank?

    # Reserved subdomains for platform use
    reserved = %w[www admin api app assets help support docs]
    !reserved.include?(request.subdomain)
  end
end

class AdminSubdomainConstraint
  def self.matches?(request)
    # Match only if subdomain is 'admin'
    request.subdomain == 'admin'
  end
end

class NoSubdomainConstraint
  def self.matches?(request)
    # Match only if there's no subdomain or it's www
    request.subdomain.blank? || request.subdomain == 'www'
  end
end