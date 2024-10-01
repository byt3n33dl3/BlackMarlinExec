<!-- markdownlint-disable MD024 -->

# Open source vulnerability disclosure personas

Personas are characters that represent different user types within a given process or workflow. They are high-level representations of a population of stakeholders that help us understand their unique needs, pain points, and other relevant details. Using Personas help to increase the quality and consistency of analysis and helps to ensure these perspectives are effectively addressed.

Personas are not job descriptions or a specific job/role (per se); They are intended to be as detailed or high-level as is appropriate for the given task at hand. From a high level we see 5 generic personas involved in an open source vulnerability disclosure. These include:

- Maintainer
- Finder
- Supplier
- Consumer
- Coordinator

Each of these people has different needs and pain points that we'll delve into more depth.

![image.png](https://github.com/ossf/wg-vulnerability-disclosures/blob/main/docs/simple-personas.png)

## Maintainer

### Role: / “I Am a...”

- Developer
- Maintainer
- Community Member
- Lead Developer
- Project Lead
- Project Member
  -- I am an open source software maintainer
  -- I create and maintain a software component

### Needs:/”My priority initiatives are...”

- Write software that I feel adds value and helps solve problems
- Desires project to be useful to others.
- Desires the project to reflect positively on their own eminence as developer (code quality)

### Pain Points:/”My challenges...”

- I need access to software, tools, techniques to write the best possible software I and my community can
- I need best practice guidance on how to secure, test, and deliver software
- May not be compensated for work on the project
- Lack of supporting resources
- Community priorities many not align with their own priorities or goals

## Finder

### Role: / “I Am a...”

- Hacker
- Researcher
- Academic
- Bug/Bounty Hunter
- Concerned Software Enthusiast
  -- I find and/or research security vulnerabilities

### Needs:/”My priority initiatives are...”

- Wants to discover vulnerabilities before threat actors.
- Wants recognition/credit for discovering complex and/or high severity vulnerabilities in order to grow their career

### Pain Points:/”My challenges...”

- Unknowns caused by projects who do not have well published and public vulnerability disclosure policies
- Developers & vendors who are not responsive
- Vulnerabilities that I discover that get exploited in the wild

## Supplier

### Role: / “I Am a...”

- Commercial Open Source Vendor
- Commercial Organization that repackages Third-party components
- Cloud Hyperscaler
- Vendor Product Security team/PSIRT
  -- I am an organization that provides support for third-party components that are used by Consumers
  -- I may be a member of an Upstream Maintainer community/project

### Needs:/”My priority initiatives are...”

- To support my downstream consumersTo participate in my upstream communitiesTo understand what SDL-like activities are done around the software I use
- To learn about vulnerabilities in the software and hardware that I supply downstream and how to fix them
- To coordinate effectively with maintainers, reporters, and other stakeholders around vulnerability disclosures
- To support my upstream maintainers with tools, advice, expertise around how to address security vulnerabilities
- To maintain some infrastructure, software, and/or services for my consumers

### Pain Points:/”My challenges...”

- During vulnerability disclosures, what parties are appropriate to engage with to develop a solution
- Providing my downstream consumers with fixes and documentation so they can react to discover vulnerabilities

## Consumer

### Role: / “I Am a...”

- End-user of software
- Commercial Organization that repackages Third-party components
- Organization using Third-party open source software
  -- I use OSS/Third-party components to run my business
  -- I use OSS components either directly or indirectly through other products

### Needs:/”My priority initiatives are...”

- To understand what SDL-like activities are done around the software I use
- To understand how my suppliers manage their supply chain
- To learn about vulnerabilities in the software and hardware that I use and how to fix them

### Pain Points:/”My challenges...”

- Forthcoming

## Coordinator

### Role: / “I Am a...”

- A CERT
- Bug Bounty Vendor
- Vulnerability Aggregator
  -- I supply or ingest information about components to consumers

### Needs:/”My priority initiatives are

- Forthcoming

### ”Pain Points:/”My challenges

- Forthcoming

To personalize some of these roles, it can be useful to put some more human-readable names behind these roles:

## Alice, the Developer

### Role

Maintainer and lead developer of a popular open-source library

### Needs

Desires their project to be useful to others

Desires the project to reflect positively on their own eminence as a developer (quality code)

### Pain Points

May not be compensated to work on the project

Lack of supporting resources

Community priorities may not align with their own priorities, or even goals

## Aby, the Vulnerability Researcher

### Role

Penetration tests software and products for vulnerabilities

### Needs

Wants to discover vulnerabilities before threat actors

Wants recognition/credit for discovering complex and/or high severity vulnerabilities in order to grow their career

### Pain Points

Unknowns caused by projects who do not have well published and public vulnerability disclosure policies

Developers & vendors who are not responsive

Vulnerabilities that they discover that get exploited in the wild

## Finn, Vulnerability Management

### Role

Detects vulnerabilities that exist in a client’s environment via scanning endpoints and the network

### Needs

Wants timely notice of new vulnerabilities in the industry

Wants to help clients discover vulnerabilities before threat actors

Wants to have suggested remediation (workarounds, patches) for vulnerabilities that are discovered

### Pain Points

No centralized industry standard location for vulnerability reports

## Cherry, the Software Developer

### Role

Develops “enterprise” software to deliver to business

### Needs

Wants to build software to solve for their customer’s use cases

Wants to be able to make use of best-of-breed open-source libraries in order to streamline software development

Wants to develop secure and high-quality software

### Pain Points

It is difficult to know how secure open-source libraries are

When open-source libraries have new vulnerabilities discovered, it is difficult to be informed of them in a timely fashion

## Jacob, Line of Business Owner

### Role

Runs and maintains the software stack for their business

### Needs

Wants their software to execute its job function while being highly reliable

Needs to maintain their IT security posture as mandated by their BISO / CISO organization

### Pain Points

BISO / CISO escalations looking for software to be patched, that does not have a patch from the vendor

Learning about vulnerabilities before the vendors have a public disclosure with a workaround or patch available

## Mei, OS / Cloud Provider

### Role

An OS vendor or cloud provider that distributes, packages, or provides software either in some form of supported “distribution” or as part of their service.

### Needs

Positively interact with upstream communities and projects to identify & remediate security vulnerabilities quickly get identified and addressed.

Share information with my communities and consumers using standardized methods.

Issue timely CVE identifiers for qualifying components and share with contributors and maintainers.

### Pain Points

Unknowns caused by projects who do not have well published and public vulnerability disclosure policies.
