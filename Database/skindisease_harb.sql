--
-- PostgreSQL database dump
--

\restrict WvTmxWQIPcFmCyoJ2BJvUTCoW01LIP9kwggP6ME97FHe0uLRBusNeRHKGuy9LbJ

-- Dumped from database version 17.7
-- Dumped by pg_dump version 18.0

-- Started on 2026-01-16 15:22:57

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 235 (class 1255 OID 16719)
-- Name: search_diseases_ranked(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.search_diseases_ranked(input_text text) RETURNS TABLE(disease_id integer, disease_name text, score integer, matched_terms text[], matched_groups text[])
    LANGUAGE sql
    AS $$
WITH terms AS (
  SELECT DISTINCT term
  FROM regexp_split_to_table(trim(input_text), '\s+') AS term
  WHERE term <> ''
),
hits AS (
  SELECT
    d.disease_id,
    d.name_th::text AS disease_name,
    t.term,
    s.symptom_group,
    CASE
      WHEN s.symptom_group IN ('BLISTER_WOUND','PAIN_BURN','SWELLING') THEN 3
      WHEN s.symptom_group IN ('ITCH','RASH_PATCH','SCALING_DRY') THEN 2
      WHEN s.symptom_group IN ('SYSTEMIC','NAIL') THEN 2
      ELSE 1
    END AS w
  FROM disease_symptoms s
  JOIN skin_diseases d ON d.disease_id = s.disease_id
  JOIN terms t ON s.symptom_text ILIKE '%' || t.term || '%'
)
SELECT
  disease_id,
  disease_name,
  SUM(w)::int AS score,
  array_agg(DISTINCT term) AS matched_terms,
  array_agg(DISTINCT symptom_group) AS matched_groups
FROM hits
GROUP BY disease_id, disease_name
ORDER BY score DESC, disease_name;
$$;


ALTER FUNCTION public.search_diseases_ranked(input_text text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16681)
-- Name: disease_symptoms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.disease_symptoms (
    symptom_id integer NOT NULL,
    disease_id integer NOT NULL,
    symptom_text text NOT NULL,
    symptom_group character varying(50)
);


ALTER TABLE public.disease_symptoms OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16680)
-- Name: disease_symptoms_symptom_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.disease_symptoms_symptom_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.disease_symptoms_symptom_id_seq OWNER TO postgres;

--
-- TOC entry 4935 (class 0 OID 0)
-- Dependencies: 221
-- Name: disease_symptoms_symptom_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.disease_symptoms_symptom_id_seq OWNED BY public.disease_symptoms.symptom_id;


--
-- TOC entry 223 (class 1259 OID 16698)
-- Name: herb_disease_map; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.herb_disease_map (
    herb_id integer NOT NULL,
    disease_id integer NOT NULL,
    evidence_level character varying(50) DEFAULT 'traditional'::character varying,
    usage_notes text
);


ALTER TABLE public.herb_disease_map OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16661)
-- Name: herbs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.herbs (
    herb_id integer NOT NULL,
    thai_name character varying(255) NOT NULL,
    scientific_name character varying(255),
    local_name character varying(255),
    description text,
    parts_used character varying(255),
    preparation text,
    properties text,
    contraindications text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.herbs OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16660)
-- Name: herbs_herb_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.herbs_herb_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.herbs_herb_id_seq OWNER TO postgres;

--
-- TOC entry 4936 (class 0 OID 0)
-- Dependencies: 217
-- Name: herbs_herb_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.herbs_herb_id_seq OWNED BY public.herbs.herb_id;


--
-- TOC entry 220 (class 1259 OID 16671)
-- Name: skin_diseases; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skin_diseases (
    disease_id integer NOT NULL,
    name_th character varying(255) NOT NULL,
    description text,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.skin_diseases OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16670)
-- Name: skin_diseases_disease_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.skin_diseases_disease_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.skin_diseases_disease_id_seq OWNER TO postgres;

--
-- TOC entry 4937 (class 0 OID 0)
-- Dependencies: 219
-- Name: skin_diseases_disease_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.skin_diseases_disease_id_seq OWNED BY public.skin_diseases.disease_id;


--
-- TOC entry 4761 (class 2604 OID 16684)
-- Name: disease_symptoms symptom_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_symptoms ALTER COLUMN symptom_id SET DEFAULT nextval('public.disease_symptoms_symptom_id_seq'::regclass);


--
-- TOC entry 4757 (class 2604 OID 16664)
-- Name: herbs herb_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herbs ALTER COLUMN herb_id SET DEFAULT nextval('public.herbs_herb_id_seq'::regclass);


--
-- TOC entry 4759 (class 2604 OID 16674)
-- Name: skin_diseases disease_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skin_diseases ALTER COLUMN disease_id SET DEFAULT nextval('public.skin_diseases_disease_id_seq'::regclass);


--
-- TOC entry 4928 (class 0 OID 16681)
-- Dependencies: 222
-- Data for Name: disease_symptoms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.disease_symptoms (symptom_id, disease_id, symptom_text, symptom_group) FROM stdin;
1	1	ผื่นแดง	RASH_PATCH
2	1	สะเก็ดขาว	SCALING_DRY
3	1	คัน	ITCH
4	1	ผิวแห้งแตก	SCALING_DRY
5	1	เป็นเรื้อรัง	OTHER
6	2	ปวดแสบปวดร้อน	PAIN_BURN
7	2	ผื่นขึ้นเป็นแนว	RASH_PATCH
8	2	ตุ่มน้ำใส	BLISTER_WOUND
9	2	เจ็บตามเส้นประสาท	PAIN_BURN
10	3	สิวอุดตัน	OTHER
11	3	ตุ่มแดงอักเสบ	OTHER
12	3	ตุ่มหนอง	OTHER
13	3	ผิวมัน	OTHER
14	3	สิวหัวดำ	OTHER
15	4	ผื่นแดง	RASH_PATCH
16	4	คัน	ITCH
17	4	ผิวแห้งลอก	SCALING_DRY
18	4	แสบ	PAIN_BURN
19	4	ผิวแตก	SCALING_DRY
20	5	ตุ่มน้ำใส	BLISTER_WOUND
21	5	แสบคัน	ITCH
22	5	เจ็บ	PAIN_BURN
23	5	เป็นซ้ำ	OTHER
24	5	ตกสะเก็ด	BLISTER_WOUND
25	6	ผื่นเป็นวง	RASH_PATCH
26	6	คัน	ITCH
27	6	ขอบผื่นชัด	RASH_PATCH
28	6	ผิวลอก	SCALING_DRY
29	7	รอยด่าง	RASH_PATCH
30	7	ด่างขาวหรือสีน้ำตาลอ่อน	RASH_PATCH
31	7	คันเล็กน้อย	ITCH
32	7	เป็นขุยละเอียด	SCALING_DRY
33	8	ผิวขาวเป็นปื้น	RASH_PATCH
34	8	ขอบปื้นชัด	RASH_PATCH
35	8	ขนในบริเวณนั้นขาว	OTHER
36	8	ไม่คัน	ITCH
37	9	ผื่นนูนแดง	RASH_PATCH
38	9	คันมาก	ITCH
39	9	ยุบหายได้เอง	OTHER
40	9	ผื่นขึ้นๆหายๆ	RASH_PATCH
41	9	บวมบริเวณใบหน้า	SWELLING
42	1	ผื่นหนา	RASH_PATCH
43	1	ผิวลอกเป็นแผ่น	SCALING_DRY
44	1	คันมาก	ITCH
45	1	แสบ	PAIN_BURN
46	1	แตกร้าวมีเลือดซิบ	SCALING_DRY
47	1	เล็บหนา	NAIL
48	1	เล็บเป็นหลุม	NAIL
49	1	เล็บเปลี่ยนสี	NAIL
50	1	ปวดข้อ	PAIN_BURN
51	1	ผื่นที่ศอกเข่า	RASH_PATCH
52	2	ปวดจี๊ดๆ	PAIN_BURN
53	2	คัน	ITCH
54	2	ผิวไวต่อการสัมผัส	OTHER
55	2	ปวดก่อนมีผื่น	RASH_PATCH
56	2	มีไข้	SYSTEMIC
57	2	อ่อนเพลีย	SYSTEMIC
58	2	ตุ่มน้ำแตกเป็นแผล	BLISTER_WOUND
59	2	ตกสะเก็ด	BLISTER_WOUND
60	2	ปวดหลังผื่นยุบ	RASH_PATCH
61	2	ผื่นขึ้นข้างเดียว	RASH_PATCH
62	3	สิวหัวขาว	OTHER
64	3	สิวอักเสบ	OTHER
65	3	สิวผด	OTHER
66	3	ก้อนสิวลึก	OTHER
67	3	เจ็บเมื่อกด	PAIN_BURN
68	3	รอยแดงหลังสิว	OTHER
69	3	รอยดำหลังสิว	OTHER
70	3	ผิวไม่เรียบ	OTHER
71	3	รูขุมขนอุดตัน	OTHER
72	4	คันมาก	ITCH
73	4	ผิวหนาตัว	OTHER
74	4	ผิวลอกเป็นขุย	SCALING_DRY
75	4	น้ำเหลืองซึม	OTHER
76	4	มีสะเก็ด	SCALING_DRY
77	4	ผิวบวมแดง	SWELLING
78	4	ผิวแตกเจ็บ	PAIN_BURN
79	4	เป็นๆหายๆ	OTHER
80	4	ระคายเคือง	OTHER
81	4	คันตอนกลางคืน	ITCH
82	5	ตุ่มน้ำเป็นกลุ่ม	BLISTER_WOUND
83	5	ปวดแสบปวดร้อน	PAIN_BURN
84	5	คันก่อนมีตุ่ม	ITCH
85	5	แผลตื้น	BLISTER_WOUND
86	5	บวมแดงรอบตุ่ม	SWELLING
87	5	เจ็บเวลาโดน	PAIN_BURN
88	5	มีไข้	SYSTEMIC
89	5	ต่อมน้ำเหลืองโต	OTHER
90	5	แผลหายแล้วกลับมาเป็นซ้ำ	BLISTER_WOUND
91	5	ตกสะเก็ดและหลุดลอก	BLISTER_WOUND
92	6	ผื่นแดงเป็นวง	RASH_PATCH
93	6	ขอบนูน	OTHER
94	6	ขอบลอก	SCALING_DRY
95	6	ลามออกด้านนอก	OTHER
96	6	คันมาก	ITCH
97	6	เป็นตามขาหนีบ	OTHER
98	6	เป็นตามลำตัว	OTHER
99	6	เป็นที่เท้า	OTHER
100	6	ผิวแตก	SCALING_DRY
101	6	คันหลังเหงื่อออก	ITCH
102	7	รอยด่างหลายจุด	RASH_PATCH
103	7	ด่างที่หน้าอกหลัง	RASH_PATCH
104	7	ขุยละเอียดเมื่อขูด	SCALING_DRY
105	7	ผิวลอกบางๆ	SCALING_DRY
106	7	เป็นมากขึ้นเวลาอากาศร้อน	OTHER
107	7	เหงื่อออกแล้วคัน	ITCH
108	7	สีผิวไม่สม่ำเสมอ	OTHER
109	7	ด่างชมพูอ่อน	RASH_PATCH
110	7	ด่างน้ำตาล	RASH_PATCH
111	7	ลามช้า	OTHER
112	8	ปื้นขาวขยาย	RASH_PATCH
113	8	ปื้นขาวหลายตำแหน่ง	RASH_PATCH
114	8	ขอบปื้นคมชัด	RASH_PATCH
115	8	สีผิวหายไปเป็นหย่อม	OTHER
116	8	ขนขาวในปื้น	RASH_PATCH
117	8	ไม่มีอาการคัน	ITCH
118	8	ไวต่อแดด	OTHER
119	8	ปื้นขาวที่มือ	RASH_PATCH
120	8	ปื้นขาวที่หน้า	RASH_PATCH
121	8	เป็นเรื้อรัง	OTHER
122	9	ผื่นนูนย้ายที่ได้	RASH_PATCH
124	9	ผื่นขึ้นเร็ว	RASH_PATCH
125	9	ยุบภายใน 24 ชั่วโมง	OTHER
126	9	บวมรอบตา	SWELLING
127	9	ปากบวม	SWELLING
128	9	คอบวม	SWELLING
129	9	แน่นหน้าอก	OTHER
130	9	ผื่นกำเริบหลังอาหาร	RASH_PATCH
131	9	ผื่นกำเริบหลังยา	RASH_PATCH
132	1	ผื่นแดงหนา	RASH_PATCH
133	1	ผิวเป็นปื้นหนา	RASH_PATCH
134	1	ขอบผื่นชัด	RASH_PATCH
135	1	สะเก็ดสีขาวเงิน	SCALING_DRY
136	1	ลอกเป็นแผ่น	SCALING_DRY
137	1	ผิวแตกเจ็บ	PAIN_BURN
138	1	เลือดซิบเมื่อเกา	OTHER
139	1	คันเป็นๆหายๆ	ITCH
140	1	แสบตึงผิว	PAIN_BURN
141	1	เป็นบริเวณหนังศีรษะ	OTHER
142	1	รังแคหนา	OTHER
143	1	ผื่นหลังหู	RASH_PATCH
144	1	เป็นบริเวณข้อศอก	OTHER
145	1	เป็นบริเวณเข่า	OTHER
146	1	เป็นบริเวณหลัง	OTHER
149	1	เล็บล่อนแยกจากเนื้อเล็บ	NAIL
151	1	ข้อบวมตึง	SWELLING
152	1	กำเริบเมื่อเครียด	OTHER
153	1	กำเริบเมื่ออากาศแห้ง	SCALING_DRY
154	1	ผื่นกำเริบหลังติดเชื้อ	RASH_PATCH
155	2	ปวดแปลบเป็นระยะ	PAIN_BURN
156	2	ปวดร้าวตามแนวเส้นประสาท	PAIN_BURN
157	2	ปวดก่อนผื่นขึ้น	RASH_PATCH
158	2	ผื่นแดงเป็นแนว	RASH_PATCH
159	2	ผื่นขึ้นเป็นแถบ	RASH_PATCH
161	2	ตุ่มน้ำใสเรียงกลุ่ม	BLISTER_WOUND
162	2	ตุ่มน้ำแตก	BLISTER_WOUND
163	2	แผลเปียก	BLISTER_WOUND
166	2	แสบ	PAIN_BURN
167	2	เจ็บเมื่อสัมผัส	PAIN_BURN
169	2	มีไข้ต่ำ	SYSTEMIC
170	2	หนาวสั่น	SYSTEMIC
171	2	ปวดศีรษะ	PAIN_BURN
173	2	ปวดหลัง/ซี่โครง	PAIN_BURN
174	2	ปวดหลังผื่นหาย	RASH_PATCH
175	2	ปวดนานหลังเป็นงูสวัด	PAIN_BURN
178	3	สิวอักเสบแดง	OTHER
179	3	สิวหัวหนอง	OTHER
180	3	สิวผดเม็ดเล็ก	OTHER
182	3	สิวเจ็บ	PAIN_BURN
188	3	หลุมสิว	OTHER
189	3	สิวขึ้นซ้ำบริเวณเดิม	OTHER
190	3	สิวขึ้นช่วงฮอร์โมน	OTHER
191	3	สิวขึ้นที่หลัง	OTHER
192	3	สิวขึ้นที่หน้าอก	OTHER
193	3	สิวอุดตันที่หน้าผาก	OTHER
194	3	อักเสบรอบรูขุมขน	OTHER
195	3	ผิวระคายเคืองจากครีม/เครื่องสำอาง	OTHER
198	4	ผื่นแดงเป็นปื้น	RASH_PATCH
199	4	ผิวแห้งมาก	SCALING_DRY
200	4	ผิวลอก	SCALING_DRY
203	4	บวมแดง	SWELLING
205	4	มีสะเก็ดเหลือง	SCALING_DRY
206	4	ผิวหนาตัวจากการเกา	OTHER
207	4	ผิวไวต่อสบู่/น้ำหอม	OTHER
208	4	กำเริบหลังสัมผัสสารเคมี	OTHER
209	4	ผื่นขึ้นที่ข้อพับ	RASH_PATCH
210	4	ผื่นที่มือ	RASH_PATCH
211	4	ผื่นที่หน้า	RASH_PATCH
212	4	ผื่นเป็นๆหายๆ	RASH_PATCH
214	4	คันหลังเหงื่อออก	ITCH
215	4	มีรอยเกา	OTHER
216	4	เจ็บเมื่อผิวแตก	PAIN_BURN
218	5	แสบก่อนมีตุ่ม	PAIN_BURN
220	5	ตุ่มน้ำใสเป็นกลุ่ม	BLISTER_WOUND
221	5	ตุ่มน้ำแตกเป็นแผล	BLISTER_WOUND
226	5	เป็นซ้ำที่เดิม	OTHER
227	5	เป็นหลังพักผ่อนน้อย	OTHER
228	5	เป็นหลังเครียด	OTHER
229	5	เป็นหลังมีไข้	SYSTEMIC
231	5	แผลที่ริมฝีปาก	BLISTER_WOUND
232	5	แผลที่อวัยวะเพศ	BLISTER_WOUND
233	5	แผลแสบเมื่อโดนน้ำ	BLISTER_WOUND
235	6	ขอบผื่นนูน	RASH_PATCH
236	6	ขอบผื่นแดง	RASH_PATCH
237	6	ขอบลอกเป็นขุย	SCALING_DRY
238	6	ตรงกลางผื่นจาง	RASH_PATCH
241	6	ผื่นหลายวง	RASH_PATCH
244	6	เป็นที่ลำตัว	OTHER
245	6	เป็นที่ขาหนีบ	OTHER
247	6	เป็นที่แขนขา	OTHER
248	6	ผื่นแห้งเป็นขุย	RASH_PATCH
249	6	ระคายเคืองเมื่อเกา	OTHER
250	6	เป็นซ้ำ	OTHER
252	7	รอยด่างขยาย	RASH_PATCH
253	7	ด่างขาว	RASH_PATCH
254	7	ด่างน้ำตาลอ่อน	RASH_PATCH
258	7	ขุยชัดเมื่อขูด	SCALING_DRY
260	7	คันเมื่อเหงื่อออก	ITCH
261	7	เป็นมากเวลาอากาศร้อน	OTHER
262	7	ขึ้นที่หน้าอก	OTHER
263	7	ขึ้นที่หลัง	OTHER
264	7	ขึ้นที่คอ	OTHER
266	7	เป็นซ้ำ	OTHER
267	8	ปื้นขาวขอบชัด	RASH_PATCH
271	8	ขนในปื้นขาว	RASH_PATCH
274	8	ปื้นที่มือ	RASH_PATCH
275	8	ปื้นที่หน้า	RASH_PATCH
276	8	ปื้นรอบปาก	RASH_PATCH
277	8	ปื้นรอบตา	RASH_PATCH
278	8	ปื้นที่ข้อพับ	RASH_PATCH
280	8	ขอบปื้นคม	RASH_PATCH
281	8	ปื้นค่อยๆลาม	RASH_PATCH
283	9	ผื่นเป็นปื้นนูน	RASH_PATCH
286	9	ผื่นยุบภายใน 24 ชั่วโมง	RASH_PATCH
287	9	ผื่นย้ายตำแหน่งได้	RASH_PATCH
289	9	แสบ	PAIN_BURN
292	9	หน้าบวม	SWELLING
293	9	มือเท้าบวม	SWELLING
295	9	หายใจลำบาก	OTHER
296	9	เวียนศีรษะ	OTHER
297	9	กำเริบหลังอาหาร	OTHER
298	9	กำเริบหลังยา	OTHER
299	9	กำเริบหลังแมลงกัด	OTHER
300	9	กำเริบหลังออกกำลังกาย	OTHER
301	9	กำเริบหลังอากาศเย็น	OTHER
302	9	กำเริบจากความเครียด	OTHER
303	1	ผื่นสะเก็ด	RASH_PATCH
304	1	สะเก็ดหนา	SCALING_DRY
305	1	ผิวเป็นขุย	SCALING_DRY
306	1	ผิวลอกขาว	SCALING_DRY
307	1	ผิวแตกเป็นแผล	BLISTER_WOUND
309	1	ผื่นเรื้อรัง	RASH_PATCH
310	1	ผื่นไม่หายขาด	RASH_PATCH
311	1	เป็นมานาน	OTHER
312	1	ผื่นกำเริบ	RASH_PATCH
313	1	ผื่นข้อศอก	RASH_PATCH
314	1	ผื่นเข่า	RASH_PATCH
315	1	ผื่นหนังศีรษะ	RASH_PATCH
316	1	รังแคหนามาก	OTHER
317	1	เล็บผิดปกติ	NAIL
318	1	เล็บเป็นรู	NAIL
319	1	ปวดข้อร่วมกับผื่น	RASH_PATCH
320	2	งูสวัดขึ้น	OTHER
321	2	ผื่นงูสวัด	RASH_PATCH
322	2	ปวดแสบ	PAIN_BURN
323	2	ปวดจี๊ด	PAIN_BURN
324	2	ปวดเหมือนไฟไหม้	PAIN_BURN
326	2	ผื่นเป็นแนว	RASH_PATCH
328	2	ตุ่มน้ำ	BLISTER_WOUND
330	2	แผลพุพอง	BLISTER_WOUND
331	2	ปวดหลังเป็นงูสวัด	PAIN_BURN
332	2	ปวดนานหลังหาย	PAIN_BURN
334	3	สิวขึ้นเยอะ	OTHER
335	3	สิวเห่อ	OTHER
336	3	สิวอักเสบหนัก	OTHER
337	3	สิวเป็นก้อน	OTHER
338	3	สิวไม่มีหัว	OTHER
339	3	สิวหัวปิด	OTHER
340	3	สิวหัวเปิด	OTHER
341	3	สิวใต้ผิวหนัง	OTHER
343	3	สิวที่หลัง	OTHER
344	3	สิวที่หน้าอก	OTHER
345	3	รอยสิว	OTHER
347	3	หน้ามันเป็นสิว	OTHER
348	3	แพ้ครีมเป็นสิว	OTHER
349	4	ผื่นแพ้	RASH_PATCH
350	4	ผื่นคัน	ITCH
351	4	ผิวแพ้ง่าย	OTHER
352	4	ผิวระคายเคือง	OTHER
353	4	ผิวแดงคัน	ITCH
354	4	ผื่นแพ้สารเคมี	RASH_PATCH
355	4	แพ้สบู่	OTHER
356	4	แพ้ครีม	OTHER
357	4	แพ้น้ำหอม	OTHER
360	4	ผื่นข้อพับ	RASH_PATCH
362	5	เริมขึ้น	OTHER
363	5	เริมกำเริบ	OTHER
364	5	เริมที่ปาก	OTHER
365	5	เริมที่อวัยวะเพศ	OTHER
366	5	ตุ่มน้ำเริม	BLISTER_WOUND
368	5	แสบก่อนขึ้นตุ่ม	PAIN_BURN
369	5	คันก่อนขึ้นตุ่ม	ITCH
370	5	แผลเริม	BLISTER_WOUND
371	5	เริมเป็นซ้ำ	OTHER
372	5	เริมหลังเครียด	OTHER
373	5	เริมหลังพักผ่อนน้อย	OTHER
374	6	กลากขึ้น	OTHER
375	6	ผื่นวงแดง	RASH_PATCH
376	6	ผื่นวง	RASH_PATCH
377	6	ผื่นเป็นดวง	RASH_PATCH
378	6	ผื่นขอบแดง	RASH_PATCH
379	6	ผื่นลาม	RASH_PATCH
381	6	คันหลังเหงื่อ	ITCH
382	6	กลากที่ขาหนีบ	OTHER
383	6	กลากที่ลำตัว	OTHER
384	6	กลากที่เท้า	OTHER
385	7	เกลื้อนขึ้น	OTHER
386	7	ด่างๆเป็นขุย	RASH_PATCH
387	7	ผิวด่าง	RASH_PATCH
390	7	ผิวสีไม่สม่ำเสมอ	OTHER
391	7	ขุยขาวบางๆ	SCALING_DRY
392	7	เกลื้อนที่หลัง	OTHER
393	7	เกลื้อนที่หน้าอก	OTHER
394	7	เกลื้อนเป็นซ้ำ	OTHER
395	8	ด่างขาวขึ้น	RASH_PATCH
397	8	ปื้นขาว	RASH_PATCH
398	8	สีผิวหาย	OTHER
399	8	ผิวด่าง	RASH_PATCH
401	8	ด่างขาวที่หน้า	RASH_PATCH
402	8	ด่างขาวที่มือ	RASH_PATCH
403	8	ไม่คันแต่ขาว	ITCH
404	9	ลมพิษขึ้น	OTHER
405	9	ผื่นลม	RASH_PATCH
406	9	คันทั้งตัว	ITCH
407	9	ผื่นนูนคัน	ITCH
409	9	ผื่นยุบเอง	RASH_PATCH
410	9	ผื่นหายเร็ว	RASH_PATCH
411	9	แพ้อาหาร	OTHER
412	9	แพ้ยา	OTHER
415	9	ตาบวม	SWELLING
416	9	ผื่นขึ้นหลังออกกำลังกาย	RASH_PATCH
417	9	ผื่นขึ้นเวลาเครียด	RASH_PATCH
\.


--
-- TOC entry 4929 (class 0 OID 16698)
-- Dependencies: 223
-- Data for Name: herb_disease_map; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.herb_disease_map (herb_id, disease_id, evidence_level, usage_notes) FROM stdin;
11	1	traditional	ต้มเปลือกมังคุดแห้งเอาน้ำล้างบริเวณผื่น วันละ 1-2 ครั้ง (ทดสอบการระคายเคืองก่อน)
3	1	traditional	ทาวุ้นว่านหางจระเข้บางๆ เพื่อลดแห้งตึง/แสบ
1	2	traditional	ตำใบพญายอพอก/ทาบริเวณผื่นเพื่อบรรเทาแสบคัน
3	2	traditional	ทาวุ้นว่านหางจระเข้เพื่อลดระคายเคือง (หลีกเลี่ยงแผลเปิดมาก)
4	3	traditional	ผงขมิ้นชันผสมน้ำทาบางๆ เฉพาะจุด (ทดสอบแพ้ก่อน)
2	3	traditional	แตงกวาฝาน/คั้นน้ำพอกเพื่อลดระคายเคืองและให้ความชุ่มชื้น
3	4	traditional	ว่านหางจระเข้ทาบางๆ วันละ 2-3 ครั้ง
12	4	traditional	ตำลึงตำพอกเพื่อลดผดผื่นคัน
1	5	traditional	พญายอทาภายนอกเพื่อลดแสบคัน (หลีกเลี่ยงแผลเปิดลึก/ติดเชื้อ)
3	5	traditional	ว่านหางจระเข้ทาบางๆ บรรเทาแสบคัน
10	6	traditional	ฝนข่ากับน้ำทาภายนอกบริเวณที่เป็น วันละ 1-2 ครั้ง
7	6	traditional	คั้นน้ำใบพลูทาภายนอก (ทดสอบการระคายเคืองก่อน)
10	7	traditional	ฝนข่ากับน้ำทาภายนอก
7	7	traditional	น้ำคั้นใบพลูทาภายนอก
2	8	traditional	แตงกวาพอกเพิ่มความชุ่มชื้นผิว (ไม่ใช่การรักษาหลัก)
3	8	traditional	ว่านหางจระเข้ทาเพื่อบรรเทาความแห้ง/ระคายเคือง
12	9	traditional	ตำลึงตำพอกเพื่อลดคัน
3	9	traditional	ว่านหางจระเข้ทาบางๆ เพื่อลดแสบคัน
\.


--
-- TOC entry 4924 (class 0 OID 16661)
-- Dependencies: 218
-- Data for Name: herbs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.herbs (herb_id, thai_name, scientific_name, local_name, description, parts_used, preparation, properties, contraindications, created_at) FROM stdin;
1	พญายอ	Clinacanthus nutans	เสลดพังพอนตัวเมีย	รักษาเริม, งูสวัด, และอีสุกอีใส,บรรเทาอาการปวดบวม, เคล็ดขัดยอก, ฟกช้ำ และแมลงกัดต่อย.	ใบ	ใช้ใบสดตำผสมเหล้าโรง, น้ำมะนาว หรือผสมเกลือ พอกบริเวณที่เป็นแผล หรือใช้เป็นยาทาเฉพาะที่.	ต้านการอักเสบ ลดอาการคัน ลดผื่น	ควรใช้ภายนอก หลีกเลี่ยงแผลเปิดขนาดใหญ่	2026-01-15 21:13:26.035845
2	แตงกวา	Cucumis sativus	แตง	พืชผักที่ช่วยให้ความชุ่มชื้นแก่ผิว	ผล	ฝานบาง ๆ หรือคั้นน้ำ พอกผิว	ลดอาการระคายเคือง ให้ความชุ่มชื้น	ควรล้างให้สะอาดก่อนใช้	2026-01-15 21:13:26.035845
3	ว่านหางจระเข้	Aloe vera	ว่านไฟไหม้	สมานแผลไฟไหม้น้ำร้อนลวก แผลสด แผลจากแสงแดด ลดการอักเสบ แสบร้อน และช่วยให้ผิวชุ่มชื้น	วุ้นจากใบ	ปอกเปลือก ล้างวุ้นให้สะอาด แล้วทาบริเวณผิว	ลดการอักเสบ ให้ความชุ่มชื้น บรรเทาอาการแสบคัน	ทดสอบการแพ้ก่อนใช้ หลีกเลี่ยงแผลลึก	2026-01-15 21:13:26.035845
4	ขมิ้นชัน	Curcuma longa	ขมิ้น	สมุนไพรต้านการอักเสบและเชื้อแบคทีเรีย	เหง้า	ฝนเหง้าสดกับน้ำ ทาบริเวณที่เป็น หรือใช้ ผงขมิ้นผสมน้ำ น้ำมันมะพร้าว ทา/พอกทั่วผิวหน้าและผิวกาย	ลดการอักเสบ ลดผื่นคัน ต้านเชื้อ	ไม่ควรใช้กับผิวที่มีแผลเปิด	2026-01-15 21:13:26.035845
5	กระเทียม	Allium sativum	กระเทียมบ้าน	สมุนไพรที่มีฤทธิ์ฆ่าเชื้อ	หัว	ขูดกระเทียมบดละเอียดพอกผิวบริเวณที่เป็น ทิ้งไว้ 20 นาที แล้วล้างออก ทำซ้ำวันละ 2 ครั้ง	ต้านเชื้อแบคทีเรียและเชื้อรา	การใช้กระเทียมสดไม่เหมาะกับบริเวณที่บอบบาง เช่น ใบหน้าโดยตรง และไม่ควรทิ้งไว้นานเกินไป (5-10 นาทีก็เพียงพอ)	2026-01-15 21:13:26.035845
6	พลูคาว	Houttuynia cordata	ผักคาวตอง	สมุนไพรลดการอักเสบและต้านเชื้อ	ใบ	นำใบสดมาล้างให้สะอาดแล้วตำให้ละเอียด นำมาพอกหรือทาบริเวณที่เป็นผื่นคัน สิว หรือแผลอักเสบ	ลดผื่นคัน ต้านเชื้อแบคทีเรีย	ควรทดสอบการแพ้ที่ท้องแขนก่อนใช้กับผิวหน้า และห้ามนำน้ำสกัดพลูคาวหยอดตาโดยเด็ดขาด 	2026-01-15 21:13:26.035845
7	พลู	Piper betle	ใบพลู	รักษาผื่นคัน ลมพิษ และอาการคันจากแมลงกัดต่อย 	ใบ	สำหรับลมพิษ/ผื่นคัน: ตำใบพลูสด 2-3 ใบให้ละเอียด ผสมเหล้าขาวเล็กน้อยทา สำหรับกลากเกลื้อน: ตำใบพลู 2-3 ใบผสมดินสอพอง แล้วทาบริเวณที่เป็น.	ฆ่าเชื้อ ลดผื่นคัน	ไม่ควรใช้กับผิวบอบบางมาก	2026-01-15 21:13:26.035845
8	กระเพรา	Ocimum tenuiflorum	กะเพราแดง	สมุนไพรต้านเชื้อและลดการอักเสบ	ใบ	นำใบกะเพราสด 1 กำมือ (สำหรับลมพิษ) หรือ 20 ใบ (สำหรับกลาก) ตำหรือขยี้ให้มีน้ำ ผสมเหล้าขาว (สำหรับลมพิษ) หรือทาเลย (กลาก) ทาวันละ 2-3 ครั้ง\nขยี้ใบกะเพราแดงสดทาหูดเช้า-เย็น (ระวังน้ำยางกัดเนื้อดี)	ลดผื่นคัน ต้านเชื้อแบคทีเรีย มีสารยับยั้งเชื้อแบคทีเรีย P.acnes และลดการอักเสบ	ทดสอบการแพ้ก่อนใช้จริง โดยเฉพาะบริเวณผิวที่บอบบาง	2026-01-15 21:13:26.035845
9	โหระพา	Ocimum basilicum	โหระพา	สมุนไพรใช้บรรเทาอาการคันและผิวหนังอักเสบ	ใบ	ใช้ใบสดตำพอกหรือประคบบริเวณแผลอักเสบ แผลสด หรือบริเวณที่ถูกแมลงกัดเพื่อลดอาการปวด	ลดการอักเสบ บรรเทาอาการคัน	ควรใช้ในปริมาณพอเหมาะ	2026-01-15 21:13:26.035845
10	ข่า	Alpinia galanga	ข่าใหญ่	สมุนไพรต้านเชื้อราและแบคทีเรีย	เหง้า	นำเหง้าข่าแก่มาฝานบางๆ หรือทุบให้ช้ำ แช่เหล้าขาวหรือเหล้าโรงสักพัก แล้วนำมาทาบริเวณที่เป็นผื่นคันหรือกลากเกลื้อนเป็นประจำ	รักษาเชื้อราผิวหนัง แก้กลากเกลื้อน ผื่นคัน ลมพิษ และโรคผิวหนังที่เกิดจากเชื้อราหรือแบคทีเรีย.	อาจระคายเคืองผิวบอบบาง	2026-01-15 21:13:26.035845
11	เปลือกมังคุดแห้ง	Garcinia mangostana	มังคุด	สมุนไพรต้านเชื้อและสมานแผล	เปลือกผลแห้ง	ใช้ผงเปลือกมังคุดผสมน้ำเปล่าหรือน้ำปูนใสเล็กน้อยให้เป็นเนื้อครีมข้น พอกบริเวณที่เป็นสิว/ผื่น/แผล 15-30 นาทีแล้วล้างออก ทำทุกวัน เช้า-เย็น.	ลดการอักเสบ สมานแผล ฆ่าเชื้อ	หลีกเลี่ยงการสูดดมผง	2026-01-15 21:13:26.035845
12	ตำลึง	Coccinia grandis	ตำลึง	สมุนไพรพื้นบ้านลดผดผื่นและผิวอักเสบ	ใบ	นำใบสดมาตำให้ละเอียด ผสมน้ำ/น้ำมะนาว/ดินสอพอง แล้วพอกหรือทาบริเวณที่เป็น, หรือนำไปปั่นผสมกับส่วนอื่น (เช่น ข้าวสาร, น้ำผึ้ง) เพื่อทำเป็นครีมพอกหน้าเพื่อลดสิวและริ้วรอย	ช่วยลดการอักเสบ แก้คัน บรรเทาผดผื่น ลมพิษ เริม งูสวัด และสิว	ในการทาน้ำตำลึงบนผิวที่อักเสบหรือผิวหน้าบอบบาง ห้ามถูแรงๆ เพราะจะยิ่งกระตุ้นให้ผิวหนังเกิดการอักเสบเพิ่มขึ้น	2026-01-15 21:13:26.035845
\.


--
-- TOC entry 4926 (class 0 OID 16671)
-- Dependencies: 220
-- Data for Name: skin_diseases; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skin_diseases (disease_id, name_th, description, created_at) FROM stdin;
1	สะเก็ดเงิน	ผื่นแดงมีขอบชัด มีสะเก็ดสีขาวเงินทับอยู่บนผื่น ผื่นแห้งไม่คันมาก หรือบางคนคันเล็กน้อย ชอบขึ้นตามข้อศอก หัวเข่า\nหนังศีรษะ หลังเล็บ (อาจมีจุดบุ๋ม) ไม่ใช่โรคติดต่อเกาแล้วสะเก็ดลอกออกเป็นแผ่นๆ เลือดออกเป็นจุดเล็กๆ เมื่อสะเก็ดหลุด 	2026-01-15 22:07:50.815374
2	งูสวัด	เกิดจากเชื้อไวรัส ทำให้เกิดผื่นและปวด แสบ เจ็บมากก่อนขึ้นผื่น 1–3 วัน ผื่นเป็นตุ่มน้ำใสเรียงเป็นแนวตามเส้นประสาท อยู่ด้านเดียวของร่างกาย ผ่าน 7–10 วัน ตุ่มน้ำแตกสะเก็ด\nตำแหน่งพบบ่อย ลำตัว รอบชายโครง ใบหน้า	2026-01-15 22:07:50.815374
3	สิว	การอักเสบของรูขุมขน มีตุ่มแดงหรือตุ่มหนอง	2026-01-15 22:07:50.815374
4	ผิวหนังอักเสบ	ผิวแดง คัน แห้ง อักเสบ ผื่นแดง คันมาก ผิวแห้ง แตก ลอก บางรายมีน้ำเหลืองซึมเวลารุนแรง	2026-01-15 22:07:50.815374
5	เริม	โรคผิวหนังจากเชื้อไวรัส ตุ่มน้ำเล็กๆ ใสๆ รวมกันเป็นกลุ่ม ปวด แสบร้อน หรือคันก่อนผื่นขึ้นเป็นๆ หายๆ ได้	2026-01-15 22:07:50.815374
6	กลาก	ผื่นเป็นวงกลม ขอบนูนชัด ตรงกลางผื่นซีดหรือแห้งกว่า คันมาก เป็นโรคเชื้อรา ติดต่อได้	2026-01-15 22:07:50.815374
7	เกลื้อน	ผื่นเป็นปื้นสีต่างจากผิวเดิม เช่นขาวกว่าผิว น้ำตาล ชมพู ผิวลอกเป็นขุยละเอียดมากๆ ไม่คันหรือคันเล็กน้อย	2026-01-15 22:07:50.815374
8	ด่างขาว	ปื้นผิวขาวล้วน ไม่มีสะเก็ด ไม่คัน ไม่อักเสบ ขอบคมชัด เกิดจากเม็ดสีผิวเสีย ไม่ใช่เชื้อรา ไม่ติดต่อ	2026-01-15 22:07:50.815374
9	ลมพิษ	ผื่นนูนแดง คันมาก ลักษณะเหมือนโดนยุงกัดแต่มากกว่า อยู่ไม่นาน ได้แล้วหายได้ภายใน 24 ชั่วโมง กดแล้วผื่นซีด	2026-01-15 22:07:50.815374
\.


--
-- TOC entry 4938 (class 0 OID 0)
-- Dependencies: 221
-- Name: disease_symptoms_symptom_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.disease_symptoms_symptom_id_seq', 532, true);


--
-- TOC entry 4939 (class 0 OID 0)
-- Dependencies: 217
-- Name: herbs_herb_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.herbs_herb_id_seq', 12, true);


--
-- TOC entry 4940 (class 0 OID 0)
-- Dependencies: 219
-- Name: skin_diseases_disease_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skin_diseases_disease_id_seq', 9, true);


--
-- TOC entry 4768 (class 2606 OID 16688)
-- Name: disease_symptoms disease_symptoms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_symptoms
    ADD CONSTRAINT disease_symptoms_pkey PRIMARY KEY (symptom_id);


--
-- TOC entry 4770 (class 2606 OID 16697)
-- Name: disease_symptoms disease_symptoms_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_symptoms
    ADD CONSTRAINT disease_symptoms_unique UNIQUE (disease_id, symptom_text);


--
-- TOC entry 4774 (class 2606 OID 16705)
-- Name: herb_disease_map herb_disease_map_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herb_disease_map
    ADD CONSTRAINT herb_disease_map_pkey PRIMARY KEY (herb_id, disease_id);


--
-- TOC entry 4764 (class 2606 OID 16669)
-- Name: herbs herbs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herbs
    ADD CONSTRAINT herbs_pkey PRIMARY KEY (herb_id);


--
-- TOC entry 4766 (class 2606 OID 16679)
-- Name: skin_diseases skin_diseases_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skin_diseases
    ADD CONSTRAINT skin_diseases_pkey PRIMARY KEY (disease_id);


--
-- TOC entry 4771 (class 1259 OID 16695)
-- Name: idx_symptom_disease; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_symptom_disease ON public.disease_symptoms USING btree (disease_id);


--
-- TOC entry 4772 (class 1259 OID 16694)
-- Name: idx_symptom_text; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_symptom_text ON public.disease_symptoms USING btree (symptom_text);


--
-- TOC entry 4775 (class 2606 OID 16689)
-- Name: disease_symptoms disease_symptoms_disease_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disease_symptoms
    ADD CONSTRAINT disease_symptoms_disease_id_fkey FOREIGN KEY (disease_id) REFERENCES public.skin_diseases(disease_id) ON DELETE CASCADE;


--
-- TOC entry 4776 (class 2606 OID 16711)
-- Name: herb_disease_map herb_disease_map_disease_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herb_disease_map
    ADD CONSTRAINT herb_disease_map_disease_id_fkey FOREIGN KEY (disease_id) REFERENCES public.skin_diseases(disease_id) ON DELETE CASCADE;


--
-- TOC entry 4777 (class 2606 OID 16706)
-- Name: herb_disease_map herb_disease_map_herb_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.herb_disease_map
    ADD CONSTRAINT herb_disease_map_herb_id_fkey FOREIGN KEY (herb_id) REFERENCES public.herbs(herb_id) ON DELETE CASCADE;


-- Completed on 2026-01-16 15:22:58

--
-- PostgreSQL database dump complete
--

\unrestrict WvTmxWQIPcFmCyoJ2BJvUTCoW01LIP9kwggP6ME97FHe0uLRBusNeRHKGuy9LbJ

