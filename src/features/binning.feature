Feature: Ensuring a binning tool matches the bioboxes specification

  Scenario: An empty biobox.yaml file
    When I run the bash command:
    """
      sleep 30
    """
    Then the exit status should be 0
