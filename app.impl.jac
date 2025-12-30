def analyze_article(article: any, source: any) -> str by llm(incl_info=("Analyze this article for credibility. Consider source reputation, writing quality, fact-checking. Return ONLY a JSON string with this exact structure: {\"credibility_score\": <number 0-100>, \"reasoning\": \"<explanation>\"}"));

def detect_bias(content: str) -> str by llm(incl_info=("Detect political bias in this content. Analyze word choice, framing, balance. Return ONLY a JSON string: {\"bias_score\": <number -100 to 100>, \"explanation\": \"<text>\"}"));

def detect_polarization(content: str) -> str by llm(incl_info=("Measure how polarizing this language is. Look for emotional language, us vs them framing. Return ONLY a number between 0-100 as a string."));

def extract_claims(content: str) -> str by llm(incl_info=("Extract factual claims from this content. Return ONLY a JSON array of strings: [\"claim 1\", \"claim 2\", \"claim 3\"]"));

def summarize_article(content: str) -> str by llm(incl_info=("Summarize this article in 60-80 words, 3-4 sentences. Focus on key facts, maintain neutral tone."));
